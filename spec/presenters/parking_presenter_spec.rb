# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParkingPresenter do
  describe '.entrance_ticket' do
    context 'with created status' do
      let(:parking) { create(:parking, plate: 'ABC-1234') }
      let(:result) { Parkings::EnterService::Result.new(parking, :created) }

      it 'returns created response' do
        response = described_class.entrance_ticket(result)

        expect(response).to eq({
          id: parking.id,
          plate: 'ABC-1234',
          message: 'Entrada registrada com sucesso'
        })
      end
    end

    context 'with already_active status' do
      let(:parking) { create(:parking, plate: 'ABC-1234', started_at: 30.minutes.ago) }
      let(:result) { Parkings::EnterService::Result.new(parking, :already_active) }

      it 'returns already active response with duration' do
        response = described_class.entrance_ticket(result)

        expect(response[:id]).to eq(parking.id)
        expect(response[:plate]).to eq('ABC-1234')
        expect(response[:message]).to eq('Veículo já cadastrado e com estacionamento em aberto')
        expect(response[:time]).to match(/Duração atual: \d+ minutos?/)
      end
    end

    context 'with paid_not_left status' do
      let(:parking) { create(:parking, :paid, plate: 'ABC-1234') }
      let(:result) { Parkings::EnterService::Result.new(parking, :paid_not_left) }

      it 'returns paid not left response' do
        response = described_class.entrance_ticket(result)

        expect(response[:id]).to eq(parking.id)
        expect(response[:plate]).to eq('ABC-1234')
        expect(response[:message]).to include('Pagamento realizado')
        expect(response[:message]).to include('saída do veículo ainda não foi registrada')
      end
    end
  end

  describe '.history' do
    let(:active_parking) { create(:parking, plate: 'ABC-1234', started_at: 1.hour.ago) }
    let(:paid_parking) { create(:parking, :paid, plate: 'ABC-1234', started_at: 2.hours.ago) }
    let(:completed_parking) { create(:parking, :completed, plate: 'ABC-1234', started_at: 3.hours.ago) }

    it 'returns formatted history for all parkings' do
      parkings = [ active_parking, paid_parking, completed_parking ]
      response = described_class.history(parkings)

      expect(response.length).to eq(3)
    end

    it 'includes id, time, paid, and left status' do
      parkings = [ active_parking ]
      response = described_class.history(parkings)

      expect(response.first).to include(
        id: active_parking.id,
        paid: false,
        left: false
      )
      expect(response.first[:time]).to match(/\d+ minutos?/)
    end

    it 'shows correct paid status' do
      parkings = [ paid_parking ]
      response = described_class.history(parkings)

      expect(response.first[:paid]).to be true
      expect(response.first[:left]).to be false
    end

    it 'shows correct left status' do
      parkings = [ completed_parking ]
      response = described_class.history(parkings)

      expect(response.first[:paid]).to be true
      expect(response.first[:left]).to be true
    end

    it 'returns empty array for no parkings' do
      response = described_class.history([])
      expect(response).to eq([])
    end
  end
end
