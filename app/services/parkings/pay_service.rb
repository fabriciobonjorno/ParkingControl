# frozen_string_literal: true

module Parkings
  class PayService
    def self.call(plate:)
      normalized = PlateValidator.call!(plate)

      parking = ::Parking.by_plate(normalized).active.first
      raise StandardError, "Nenhum registro ativo encontrado para a placa informada" unless parking

      if parking.paid? && !parking.left?
        raise StandardError, "Pagamento já realizado, faça a baixa do veículo"
      end

      parking.pay! unless parking.paid?
      parking
    end
  end
end
