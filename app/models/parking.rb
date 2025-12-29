# frozen_string_literal: true

class Parking < ApplicationRecord
  PLATE_REGEX = /\A[A-Z]{3}-\d{4}\z/

  scope :by_plate, ->(plate) { where(plate: plate) }
  scope :active,   -> { where(left_at: nil) }

  validates :plate, presence: true, format: { with: PLATE_REGEX }
  validates :started_at, presence: true
  normalizes :plate, with: -> { _1.strip.upcase }


  def paid?
    paid_at.present?
  end

  def active?
    left_at.nil?
  end

  def left?
    left_at.present?
  end

  def pay!
    errors.add(:paid_at, "has already been paid") if paid?

    update!(paid_at: Time.current)
  end

  def leave!
    errors.add(:paid_at, "payment required") unless paid?
    errors.add(:left_at, "has already left") if left?

    update!(left_at: Time.current)
  end

  def elapsed_time
    Rails.cache.fetch("#{cache_key_with_version}/elapsed_time", expires_in: 5.minutes) do
      Parkings::DurationService.call(
        started_at: started_at,
        left_at: left_at
      )
    end
  end

  def self.normalize_plate(plate)
    plate.to_s.strip.upcase
  end
end
