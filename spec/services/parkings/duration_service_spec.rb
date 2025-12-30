# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parkings::DurationService do
  describe '.call' do
    context 'when started_at is nil' do
      it 'returns minimum duration' do
        result = described_class.call(started_at: nil)
        expect(result).to eq('1 minuto')
      end
    end

    context 'when left_at is nil (still parked)' do
      it 'calculates duration until now' do
        started_at = 30.minutes.ago
        result = described_class.call(started_at: started_at)
        expect(result).to match(/\d+ minutos/)
      end
    end

    context 'when left_at is present' do
      it 'calculates duration between started_at and left_at' do
        started_at = Time.zone.parse('2025-01-01 10:00:00')
        left_at = Time.zone.parse('2025-01-01 11:00:00')
        result = described_class.call(started_at: started_at, left_at: left_at)
        expect(result).to eq('1 hora')
      end
    end

    context 'with exactly 1 minute duration' do
      it 'uses singular form' do
        started_at = Time.current
        left_at = started_at + 1.minute
        result = described_class.call(started_at: started_at, left_at: left_at)
        expect(result).to eq('1 minuto')
      end
    end

    context 'with less than 1 minute duration' do
      it 'returns minimum of 1 minute' do
        started_at = Time.current
        left_at = started_at + 30.seconds
        result = described_class.call(started_at: started_at, left_at: left_at)
        expect(result).to eq('1 minuto')
      end
    end

    context 'with multiple minutes duration' do
      it 'uses plural form' do
        started_at = Time.current
        left_at = started_at + 5.minutes
        result = described_class.call(started_at: started_at, left_at: left_at)
        expect(result).to eq('5 minutos')
      end
    end

    context 'with partial minutes' do
      it 'rounds up to next minute' do
        started_at = Time.current
        left_at = started_at + 3.minutes + 30.seconds
        result = described_class.call(started_at: started_at, left_at: left_at)
        expect(result).to eq('4 minutos')
      end
    end
  end
end
