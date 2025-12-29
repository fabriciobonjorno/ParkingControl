# frozen_string_literal: true

module Parkings
  class HistoryService
    def self.call(plate:)
      normalized = PlateValidator.call!(plate)

      ::Parking
        .by_plate(normalized)
        .order(started_at: :desc)
    end
  end
end
