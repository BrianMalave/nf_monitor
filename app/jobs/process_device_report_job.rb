class ProcessDeviceReportJob < ApplicationJob
  queue_as :default

  # payload esperado:
  # {
  #   restaurant: { name:, city: },
  #   devices: [
  #     { identifier:, kind:, status:, meta: {}, maintenance: { action:, notes:, started_at:, ended_at: } }
  #   ]
  # }
  def perform(payload)
    payload = payload.deep_symbolize_keys

    restaurant_attrs = payload.fetch(:restaurant)
    devices_payload  = payload.fetch(:devices)

    ActiveRecord::Base.transaction do
      name = restaurant_attrs.fetch(:name).to_s.strip
      city = restaurant_attrs.fetch(:city).to_s.strip

      restaurant = Restaurant.find_or_create_by!(
        name: name,
        city: city
      )

      devices_payload.each do |d|
        d = d.deep_symbolize_keys

        device = restaurant.devices.find_or_initialize_by(identifier: d.fetch(:identifier))
        device.kind = d.fetch(:kind)
        device.status = d.fetch(:status)
        device.last_reported_at = Time.current
        device.save!  # valida modelo (presence/enums/uniqueness)

        device.device_reports.create!(
          reported_status: d.fetch(:status),
          reported_at: Time.current,
          payload: (d[:meta] || {})
        )

        if d[:maintenance].present?
          m = d[:maintenance].deep_symbolize_keys

          device.maintenance_logs.create!(
            action: m.fetch(:action),
            notes: m[:notes],
            started_at: m[:started_at].present? ? Time.parse(m[:started_at].to_s) : Time.current,
            ended_at: m[:ended_at].present? ? Time.parse(m[:ended_at].to_s) : nil
          )
        end
      end

      restaurant.recalculate_status!
    end
  end
end