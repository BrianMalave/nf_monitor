class Device < ApplicationRecord
  belongs_to :restaurant
  has_many :device_reports, dependent: :destroy
  has_many :maintenance_logs, dependent: :destroy

  enum :kind, {
    pos: 0,
    printer: 1,
    network: 2,
    other: 99
  }

  enum :status, {
    operational: 0,
    failing: 1,
    maintenance: 2,
    offline: 3
  }

  validates :identifier, presence: true
  validates :identifier, uniqueness: { scope: :restaurant_id }
  validates :kind, presence: true
  validates :status, presence: true
end