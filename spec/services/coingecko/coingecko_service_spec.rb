require 'rails_helper'
require 'ostruct'

RSpec.describe Coingecko::CoingeckoService, type: :service do
  let(:crypto_currency) { "bitcoin" }
  let(:target_currency) { "usd" }
  let(:service) { described_class.new(crypto_currency, target_currency) }
  let(:base_url) { "https://api.coingecko.com/api/v3" }

  before do
    allow(Rails.application.credentials).to receive(:coingecko).and_return(
      double(
        base_url: base_url,
        api_key: "test_api_key"
      )
    )
  end

  describe '#call' do
    context 'when the request is successful' do
      before do
        stub_request(:get, /#{base_url}\/simple\/price/)
          .with(
            headers: {
              'Accept' => 'application/json'
            }
          )
          .to_return(
            status: 200,
            body: {
              "bitcoin" => {
                "usd" => 50000.0000,
                "last_updated_at" => 1234567890
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns success with price data' do
        result = service.call

        expect(result.success?).to be_truthy
        expect(result.data[:status]).to eq("success")
        expect(result.data[:data][:prices]).to include({ "bitcoin"=>{ "usd"=>"50.000,00", "last_updated_at"=>1234567890 } })
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:get, /#{base_url}\/simple\/price/)
          .to_return(status: 500, body: "Internal Server Error")
      end

      it 'returns failure with error message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include("Coingecko error response")
      end
    end

    context 'when currency is not allowed' do
      let(:crypto_currency) { "invalid_currency" }

      it 'returns failure with invalid currency message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:details]).to eq("Invalid currency")
      end
    end

    context 'when crypto currency is missing' do
      let(:crypto_currency) { "" }

      it 'raises ArgumentError' do
        expect { service }.to raise_error(ArgumentError)
      end
    end

    context 'when target currency is missing' do
      let(:target_currency) { "" }

      it 'raises ArgumentError' do
        expect { service }.to raise_error(ArgumentError)
      end
    end
  end
end
