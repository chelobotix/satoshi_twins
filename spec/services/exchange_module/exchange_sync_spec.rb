require 'rails_helper'

RSpec.describe ExchangeModule::ExchangeSync, type: :service do
  let(:user) { create(:user) }
  let(:bitcoin) { Currency.find_by(name: 'bitcoin') }
  let(:usd) { Currency.find_by(name: 'usd') }
  let(:exchange_rate) { 50000.0 }
  let(:amount) { 0.1 }
  let(:source_crypto) { bitcoin }
  let(:target_crypto) { usd }
  let(:source_wallet) { create(:wallet, user:, currency: bitcoin, amount: 1.0) }
  let(:target_wallet) { create(:wallet, user:, currency: usd, amount: 1000.0) }
  let(:service) { described_class.new(exchange_rate:, amount:, source_crypto:, target_crypto:, user:, source_wallet:, target_wallet:) }

  describe '#call' do
    context 'when exchange is successful' do
      it 'creates exchange and wallet exchange records' do
        expect { service.call }.to change(Exchange, :count).by(1)
          .and change(WalletExchange, :count).by(1)
      end

      it 'updates wallet amounts correctly' do
        service.call

        source_wallet.reload
        target_wallet.reload

        expect(source_wallet.amount).to eq(0.9) # 1.0 - 0.1
        expect(target_wallet.amount).to eq(6000.0) # 1000.0 + (0.1 * 50000.0)
      end

      it 'returns success with wallet exchange data' do
        result = service.call

        expect(result.success?).to be_truthy
        expect(result.data[:status]).to eq("success")
        expect(result.data[:wallet_exchange]).to be_present
      end

      it 'sets exchange state to completed' do
        result = service.call
        exchange = result.data[:wallet_exchange].exchange
        exchange.reload

        expect(exchange.aasm_state).to eq("completed")
      end
    end

    context 'when exchange fails' do
      before do
        allow(Exchange).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Exchange.new))
      end

      it 'returns failure with error message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to be_present
      end

      it 'does not create exchange records' do
        expect { service.call }.not_to change(Exchange, :count)
        expect { service.call }.not_to change(WalletExchange, :count)
      end

      it 'does not update wallet amounts' do
        original_source_amount = source_wallet.amount
        original_target_amount = target_wallet.amount

        service.call

        expect(source_wallet.reload.amount).to eq(original_source_amount)
        expect(target_wallet.reload.amount).to eq(original_target_amount)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(source_wallet).to receive(:update!).and_raise(StandardError.new("Unexpected error"))
      end

      it 'returns failure with error message' do
        result = service.call

        expect(result.success?).to be_falsey
        expect(result.error[:status]).to eq("failed")
        expect(result.error[:error]).to include("Unexpected error")
      end
    end
  end
end
