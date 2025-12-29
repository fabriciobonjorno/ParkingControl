# frozen_string_literal: true

module Parkings
  class EnterService
    Result = Struct.new(:parking, :status)

    def self.call(plate:)
      normalized = PlateValidator.call!(plate)

      ::Parking.transaction do
        active = ::Parking.by_plate(normalized).active.lock.first

        if active
          if active.paid?
            return Result.new(active, :paid_not_left)
          end

          return Result.new(active, :already_active)
        end

        parking = ::Parking.create!(
          plate: normalized,
          started_at: Time.zone.now
        )

        Result.new(parking, :created)
      end
    end
  end
end
