require 'rails_helper'

RSpec.describe Coingecko::CoingeckoService, type: :service do
  describe '#call' do
    context 'when parameters are valid' do
      it 'returns success with market data' do
        service = described_class.new('bitcoin', 'usd')
        result = service.call

        expect(result.success?).to be_truthy
        expect(result.data[:status]).to eq('success')
        expect(result.data[:data]).to include('bitcoin')
      end
    end

    context 'when crypto currency is missing' do
      it 'raises ArgumentError' do
        expect { described_class.new(nil, 'usd') }.to raise_error(ArgumentError)
      end
    end

    context 'when target currency is missing' do
      it 'raises ArgumentError' do
        expect { described_class.new('bitcoin', nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when currency is not allowed' do
      it 'returns failure with invalid currency message' do
        service = described_class.new('invalid_currency', 'usd')
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.data[:status]).to eq('failed')
        expect(result.data[:details]).to eq('Invalid currency')
      end
    end

    context 'when API request fails' do
      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError.new('API Error'))
      end

      it 'returns failure with error details' do
        service = described_class.new('bitcoin', 'usd')
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.data[:status]).to eq('failed')
        expect(result.data[:details]).to eq('API Error')
      end
    end
  end
end
