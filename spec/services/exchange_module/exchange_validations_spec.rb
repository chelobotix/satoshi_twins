require 'rails_helper'

RSpec.describe ExchangeModule::ExchangeValidations, type: :service do
  let(:user) { create(:user) }
  let(:bitcoin) { Currency.find_by(name: 'bitcoin') }
  let(:usd) { Currency.find_by(name: 'usd') }
  let(:exchange_rate) { 50000.0 }
  let(:amount) { 0.1 }
  let(:source_crypto) { Currency.find_by(name: 'bitcoin') }
  let(:target_crypto) { Currency.find_by(name: 'usd') }
  let(:service) { described_class.new(exchange_rate:, amount:, source_crypto:, target_crypto:, user:) }

  describe '#call' do
    context 'when all validations pass' do
      before do
        create(:wallet, user:, currency: bitcoin, amount: 1.0)
        create(:wallet, user:, currency: usd, amount: 1000.0)
      end

      it 'returns success with wallet data' do
        result = service.call

        expect(result.success?).to be_truthy
        expect(result.data[:status]).to eq("success")
        expect(result.data[:data][:source_wallet]).to be_present
        expect(result.data[:data][:target_wallet]).to be_present
      end
    end

    context 'when exchange rate is invalid' do
      let(:exchange_rate) { nil }

      it 'returns failure with invalid exchange rate message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include(I18n.t("exchange.invalid_exchange_rate"))
      end
    end

    context 'when currencies are invalid' do
      let(:source_crypto) { Currency.find_by(name: 'invalid_source') }
      let(:target_crypto) { Currency.find_by(name: 'invalid_target') }

      it 'returns failure with invalid currencies message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include("Invalid currencies. Allowed: bitcoin, usd")
      end
    end

    context 'when wallets are not found' do
      it 'returns failure with wallet not found message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include(I18n.t("exchange.wallet_not_found"))
      end
    end

    context 'when insufficient funds' do
      before do
        create(:wallet, user:, currency: bitcoin, amount: 0.05)
        create(:wallet, user:, currency: usd, amount: 1000.0)
      end

      it 'returns failure with insufficient funds message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include("Insufficient funds, available: 0.05")
      end
    end
  end
end
