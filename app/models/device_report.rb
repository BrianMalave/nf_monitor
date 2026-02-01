class DeviceReport < ApplicationRecord
  belongs_to :device

  enum :reported_status, {
    operational: 0,
    failing: 1,
    maintenance: 2,
    offline: 3
  }

  validates :reported_status, presence: true
  validates :reported_at, presence: true
end