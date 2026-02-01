class MaintenanceLog < ApplicationRecord
  belongs_to :device

  validates :action, presence: true
  validates :started_at, presence: true

  validate :ended_at_after_started_at

  private

  def ended_at_after_started_at
    return if ended_at.blank?

    if ended_at < started_at
      errors.add(:ended_at, "must be after started_at")
    end
  end
end