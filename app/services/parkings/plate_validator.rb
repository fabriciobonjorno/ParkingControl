# frozen_string_literal: true

module Parkings
  class PlateValidator
    def self.call!(plate)
      normalized = Parking.normalize_plate(plate)
      raise StandardError, "Invalid Plate" unless normalized.match?(Parking::PLATE_REGEX)
      normalized
    end
  end
end
