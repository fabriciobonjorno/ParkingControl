# frozen_string_literal: true

module Parkings
  class LeaveService
    def self.call(plate:)
      normalized = PlateValidator.call!(plate)

      parking = ::Parking.by_plate(normalized).active.first
      raise StandardError, "Nenhum registro ativo encontrado para a placa informada" unless parking
      raise StandardError, "Pagamento não realizado" unless parking.paid?

      parking.leave!
      parking
    end
  end
end
