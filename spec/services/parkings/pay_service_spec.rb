# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parkings::PayService do
  describe '.call' do
    context 'with active unpaid parking' do
      let!(:parking) { create(:parking, plate: 'ABC-1234') }

      it 'marks parking as paid' do
        freeze_time do
          described_class.call(plate: 'ABC-1234')
          expect(parking.reload.paid_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'returns the parking record' do
        result = described_class.call(plate: 'ABC-1234')
        expect(result).to eq(parking)
      end
    end

    context 'with invalid plate format' do
      it 'raises error' do
        expect {
          described_class.call(plate: 'INVALID')
        }.to raise_error(StandardError, 'Invalid Plate')
      end
    end

    context 'when no active parking exists' do
      it 'raises error' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.to raise_error(StandardError, /Nenhum registro ativo/)
      end
    end

    context 'when parking is already paid but not left' do
      let!(:parking) { create(:parking, :paid, plate: 'ABC-1234') }

      it 'raises error' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.to raise_error(StandardError, /Pagamento já realizado/)
      end
    end

    context 'when parking has already left' do
      let!(:parking) { create(:parking, :completed, plate: 'ABC-1234') }

      it 'raises error for no active parking' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.to raise_error(StandardError, /Nenhum registro ativo/)
      end
    end

    context 'with lowercase plate' do
      let!(:parking) { create(:parking, plate: 'ABC-1234') }

      it 'normalizes and finds the parking' do
        described_class.call(plate: 'abc-1234')
        expect(parking.reload.paid?).to be true
      end
    end
  end
end
