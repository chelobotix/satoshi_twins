require 'rails_helper'

RSpec.describe OnBoardingService, type: :service do
  let(:user) { create(:user) }
  # let(:currency) { create(:currency) }

  describe '#call' do
    context 'should success' do
      it 'creates wallets with initial amounts for the user' do
        result = OnBoardingService.new(user).call

        bitcoin_wallet = user.wallets.find_by(user_id: user.id, currency: Currency.find_by(name: :bitcoin))
        usd_wallet = user.wallets.find_by(user_id: user.id, currency: Currency.find_by(name: :usd))

        expect(result.success?).to be_truthy
        expect { OnBoardingService.new(user).call }.to change(Wallet, :count).by(2)
        expect(bitcoin_wallet).to be_present
        expect(bitcoin_wallet.amount).to eq(0.98765432)

        expect(usd_wallet).to be_present
        expect(usd_wallet.amount).to eq(1000.00)
      end
    end

    context 'when currency is not found' do
      it 'logs the error and rolls back the transaction' do
        Currency.find_by(name: :bitcoin).destroy
        result = OnBoardingService.new(user).call

        bitcoin_wallet = user.wallets.find_by(user_id: user.id, currency: Currency.find_by(name: :bitcoin))
        usd_wallet = user.wallets.find_by(user_id: user.id, currency: Currency.find_by(name: :usd))

        expect(result.success?).to be_falsey
        expect { OnBoardingService.new(user).call }.to change(Wallet, :count).by(0)
        expect(bitcoin_wallet).not_to be_present

        expect(usd_wallet).not_to be_present
      end
    end
  end
end
