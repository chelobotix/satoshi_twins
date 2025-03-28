require 'rails_helper'

RSpec.describe OnBoardingService do
  let(:user) { instance_double('User') }
  let(:bitcoin_currency) { instance_double('Currency', name: "bitcoin", symbol: "BTC") }
  let(:usd_currency) { instance_double('Currency', name: :usd, symbol: "BTC") }
  let(:service) { OnBoardingService.new(user) }
  let(:logger) { instance_double('Logger') }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(logger).to receive(:error)
  end

  describe '#call' do
    context 'when everything works correctly' do
      before do
        allow(Currency).to receive(:find_by!).with(name: :bitcoin).and_return(bitcoin_currency)
        allow(Currency).to receive(:find_by!).with(name: :usd).and_return(usd_currency)

        allow(Wallet).to receive(:create!).with(user: user, currency: bitcoin_currency, amount: 0.98765432).and_return(true)
        allow(Wallet).to receive(:create!).with(user: user, currency: usd_currency, amount: 1000.00).and_return(true)
      end

      it 'creates wallets for all initial currencies' do
        service.call

        expect(Wallet).to receive(:create!).with(user: user, currency: bitcoin_currency, amount: 0.98765432)
        expect(Wallet).to receive(:create!).with(user: user, currency: usd_currency, amount: 1000.00)
      end
    end

    context 'when currency is not found' do
      before do
        allow(Currency).to receive(:find_by!).with(name: :bitcoin).and_raise(ActiveRecord::RecordNotFound, "Couldn't find Currency")
      end

      it 'logs the error and raises Rollback' do
        expect(logger).to receive(:error).with(/Record not found: Couldn't find Currency/)
        expect { service.call }.to raise_error(ActiveRecord::Rollback)
      end
    end

    context 'when wallet creation fails with negative amount' do
      before do
        allow(Currency).to receive(:find_by!).with(name: :bitcoin).and_return(bitcoin_currency)
        allow(Currency).to receive(:find_by!).with(name: :usd).and_return(usd_currency)

        allow(Wallet).to receive(:create!).with(user: user, currency: bitcoin_currency, amount: 0.98765432)
                                          .and_raise(ActiveRecord::RecordInvalid, "Amount must be greater than or equal to 0")
      end

      it 'logs the error and raises Rollback' do
        expect(logger).to receive(:error).with(/Record invalid: Amount must be greater than or equal to 0/)
        expect { service.call }.to raise_error(ActiveRecord::Rollback)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Currency).to receive(:find_by!).with(name: :bitcoin).and_return(bitcoin_currency)
        allow(Wallet).to receive(:create!).with(user: user, currency: bitcoin_currency, amount: 0.98765432)
                                          .and_raise(StandardError, "Something went wrong")
      end

      it 'logs the error and raises Rollback' do
        expect(logger).to receive(:error).with(/Can not complete the registration: Something went wrong/)
        expect { service.call }.to raise_error(ActiveRecord::Rollback)
      end
    end
  end
end
