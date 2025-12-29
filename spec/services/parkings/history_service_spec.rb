# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parkings::HistoryService do
  describe '.call' do
    context 'with valid plate' do
      let!(:parking1) { create(:parking, plate: 'ABC-1234', started_at: 2.days.ago) }
      let!(:parking2) { create(:parking, plate: 'ABC-1234', started_at: 1.day.ago) }
      let!(:other_parking) { create(:parking, plate: 'XYZ-5678') }

      it 'returns parkings for the specified plate only' do
        result = described_class.call(plate: 'ABC-1234')

        expect(result).to contain_exactly(parking1, parking2)
        expect(result).not_to include(other_parking)
      end

      it 'orders by started_at descending (most recent first)' do
        result = described_class.call(plate: 'ABC-1234')

        expect(result.first).to eq(parking2)
        expect(result.last).to eq(parking1)
      end
    end

    context 'with no parking history' do
      it 'returns empty relation' do
        result = described_class.call(plate: 'ABC-1234')
        expect(result).to be_empty
      end
    end

    context 'with invalid plate format' do
      it 'raises error' do
        expect {
          described_class.call(plate: 'INVALID')
        }.to raise_error(StandardError, 'Invalid Plate')
      end
    end

    context 'with lowercase plate' do
      let!(:parking) { create(:parking, plate: 'ABC-1234') }

      it 'normalizes and finds parkings' do
        result = described_class.call(plate: 'abc-1234')
        expect(result).to include(parking)
      end
    end

    context 'with multiple parking sessions' do
      let!(:active) { create(:parking, plate: 'ABC-1234') }
      let!(:completed) { create(:parking, :completed, plate: 'ABC-1234', started_at: 1.day.ago) }
      let!(:paid) { create(:parking, :paid, plate: 'ABC-1234', started_at: 2.days.ago) }

      it 'includes all parking sessions regardless of status' do
        result = described_class.call(plate: 'ABC-1234')
        expect(result).to contain_exactly(active, completed, paid)
      end
    end
  end
end
