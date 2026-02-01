class Restaurant < ApplicationRecord
  has_many :devices, dependent: :destroy

  enum :status, {
    operational: 0,
    warning: 1,
    problem: 2
  }

  validates :name, presence: true
  validates :city, presence: true

  def recalculate_status!
    device_statuses = devices.pluck(:status)

    new_status =
      if device_statuses.include?("offline") || device_statuses.include?("failing")
        :problem
      elsif device_statuses.include?("maintenance")
        :warning
      else
        :operational
      end

    update!(status: new_status)
  end
end