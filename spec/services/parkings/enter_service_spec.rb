# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parkings::EnterService do
  describe '.call' do
    context 'with valid plate and no existing parking' do
      it 'creates a new parking record' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.to change(Parking, :count).by(1)
      end

      it 'returns result with created status' do
        result = described_class.call(plate: 'ABC-1234')

        expect(result.status).to eq(:created)
        expect(result.parking).to be_persisted
        expect(result.parking.plate).to eq('ABC-1234')
      end

      it 'sets started_at to current time' do
        freeze_time do
          result = described_class.call(plate: 'ABC-1234')
          expect(result.parking.started_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    context 'with lowercase plate' do
      it 'normalizes plate to uppercase' do
        result = described_class.call(plate: 'abc-1234')
        expect(result.parking.plate).to eq('ABC-1234')
      end
    end

    context 'with whitespace in plate' do
      it 'strips whitespace' do
        result = described_class.call(plate: '  ABC-1234  ')
        expect(result.parking.plate).to eq('ABC-1234')
      end
    end

    context 'with invalid plate format' do
      it 'raises error' do
        expect {
          described_class.call(plate: 'INVALID')
        }.to raise_error(StandardError, 'Invalid Plate')
      end
    end

    context 'when vehicle is already actively parked' do
      let!(:existing) { create(:parking, plate: 'ABC-1234') }

      it 'does not create a new record' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.not_to change(Parking, :count)
      end

      it 'returns result with already_active status' do
        result = described_class.call(plate: 'ABC-1234')

        expect(result.status).to eq(:already_active)
        expect(result.parking).to eq(existing)
      end
    end

    context 'when vehicle has paid but not left' do
      let!(:existing) { create(:parking, :paid, plate: 'ABC-1234') }

      it 'returns result with paid_not_left status' do
        result = described_class.call(plate: 'ABC-1234')

        expect(result.status).to eq(:paid_not_left)
        expect(result.parking).to eq(existing)
      end
    end

    context 'when vehicle has completed previous parking' do
      let!(:completed) { create(:parking, :completed, plate: 'ABC-1234') }

      it 'creates a new parking record' do
        expect {
          described_class.call(plate: 'ABC-1234')
        }.to change(Parking, :count).by(1)
      end

      it 'returns result with created status' do
        result = described_class.call(plate: 'ABC-1234')
        expect(result.status).to eq(:created)
      end
    end
  end
end
