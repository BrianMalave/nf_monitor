class Api::V1::RestaurantsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    restaurants = Restaurant
      .left_joins(:devices)
      .select("restaurants.*, COUNT(devices.id) AS devices_count")
      .group("restaurants.id")
      .order("restaurants.name ASC")

    render json: restaurants.map { |r|
      {
        id: r.id,
        name: r.name,
        city: r.city,
        status: r.status,
        devices_count: r.attributes["devices_count"].to_i
      }
    }
  end

  def show
    restaurant = Restaurant.find(params[:id])

    devices = restaurant.devices
      .includes(:device_reports, :maintenance_logs)
      .order(:identifier)

    render json: {
      id: restaurant.id,
      name: restaurant.name,
      city: restaurant.city,
      status: restaurant.status,
      devices: devices.map { |d|
        last_report = d.device_reports.order(reported_at: :desc).first
        last_maint  = d.maintenance_logs.order(started_at: :desc).first

        {
          id: d.id,
          identifier: d.identifier,
          kind: d.kind,
          status: d.status,
          last_report: last_report && {
            reported_at: last_report.reported_at&.iso8601,
            reported_status: last_report.reported_status,
            payload: last_report.payload
          },
          last_maintenance: last_maint && {
            action: last_maint.action,
            notes: last_maint.notes,
            started_at: last_maint.started_at&.iso8601,
            ended_at: last_maint.ended_at&.iso8601
          }
        }
      }
    }
  end
end