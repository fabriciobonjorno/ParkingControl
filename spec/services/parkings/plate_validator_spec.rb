# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parkings::PlateValidator do
  describe '.call!' do
    context 'with valid plate format' do
      it 'returns normalized plate' do
        result = described_class.call!('ABC-1234')
        expect(result).to eq('ABC-1234')
      end

      it 'normalizes lowercase to uppercase' do
        result = described_class.call!('abc-1234')
        expect(result).to eq('ABC-1234')
      end

      it 'strips whitespace' do
        result = described_class.call!('  ABC-1234  ')
        expect(result).to eq('ABC-1234')
      end

      it 'handles mixed case' do
        result = described_class.call!('AbC-1234')
        expect(result).to eq('ABC-1234')
      end
    end

    context 'with invalid plate format' do
      it 'raises error for missing hyphen' do
        expect {
          described_class.call!('ABC1234')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for too few letters' do
        expect {
          described_class.call!('AB-1234')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for too many letters' do
        expect {
          described_class.call!('ABCD-1234')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for too few numbers' do
        expect {
          described_class.call!('ABC-123')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for too many numbers' do
        expect {
          described_class.call!('ABC-12345')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for empty string' do
        expect {
          described_class.call!('')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for nil' do
        expect {
          described_class.call!(nil)
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for random text' do
        expect {
          described_class.call!('invalid')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for numbers in letter positions' do
        expect {
          described_class.call!('123-1234')
        }.to raise_error(StandardError, 'Invalid Plate')
      end

      it 'raises error for letters in number positions' do
        expect {
          described_class.call!('ABC-ABCD')
        }.to raise_error(StandardError, 'Invalid Plate')
      end
    end
  end
end
