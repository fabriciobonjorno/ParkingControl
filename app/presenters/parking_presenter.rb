# frozen_string_literal: true

class ParkingPresenter
  class << self
    # 🚗 POST /parkings
    def entrance_ticket(result)
      case result.status
      when :created
        created_response(result.parking)
      when :already_active
        already_active_response(result.parking)
      when :paid_not_left
        paid_not_left_response(result.parking)
      end
    end

    # 📜 GET /parking/:plate
    def history(parkings)
      parkings.map { |parking| history_response(parking) }
    end

    private

    def created_response(parking)
      {
        id: parking.id,
        plate: parking.plate,
        message: "Entrada registrada com sucesso"
      }
    end

  def already_active_response(parking)
    {
      id: parking.id,
      plate: parking.plate,
      message: "Veículo já cadastrado e com estacionamento em aberto",
      time: "Duração atual: #{elapsed_time(parking)}"
    }
  end

  def paid_not_left_response(parking)
    {
      id: parking.id,
      plate: parking.plate,
      message: "Pagamento realizado em #{parking.paid_at.strftime('%d/%m/%Y')}, mas a saída do veículo ainda não foi registrada"
    }
  end

    def history_response(parking)
      {
        id: parking.id,
        time: elapsed_time(parking),
        paid: parking.paid?,
        left: parking.left?
      }
    end

    def elapsed_time(parking)
      Parkings::DurationService.call(
        started_at: parking.started_at,
        left_at: parking.left_at
      )
    end
  end
end
