module ExchangeModule
  class ExchangeSync
    include ResultUtils::Builder

    def initialize(exchange_rate:, amount:, source_crypto:, target_crypto:, user:, source_wallet:, target_wallet:)
      @exchange_rate = exchange_rate
      @amount = amount
      @source_crypto = source_crypto
      @target_crypto = target_crypto
      @user = user
      @source_wallet = source_wallet
      @target_wallet = target_wallet
      @wallet_exchange = nil
      @errors = []
    end

    def call
      handle_exchange

      if @errors.any?
        failure(data: { status: "failed", error: @errors.join(",") })
      else
        success(data: { status: "success", wallet_exchange: @wallet_exchange })
      end
    end

    private

    def handle_exchange
      ApplicationRecord.transaction do
        create_exchange
        update_wallets
      end

      @exchange&.update!(aasm_state: :completed)

    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
    rescue StandardError  => e
      @errors << e.message
    end

    def create_exchange
      @exchange = Exchange.create!(
        send_amount: @amount,
        receive_amount: @amount * @exchange_rate,
        exchange_rate: @exchange_rate,
        aasm_state: :processing,
        send_currency_id: @source_crypto.id,
        receive_currency_id: @target_crypto.id
      )

      @wallet_exchange = WalletExchange.create!(
        user_id: @user.id,
        source_wallet_amount_before: @source_wallet&.amount,
        source_wallet_amount_after: @source_wallet&.amount - @amount,
        target_wallet_amount_before: @target_wallet&.amount,
        target_wallet_amount_after: @target_wallet&.amount + (@amount * @exchange_rate),
        exchange_id: @exchange.id,
        source_wallet_id: @source_wallet&.id,
        target_wallet_id: @target_wallet&.id
      )
    end

    def update_wallets
      exchange_result = @amount * @exchange_rate
      @source_wallet&.update!(amount: @source_wallet&.amount - @amount)
      @target_wallet&.update!(amount: @target_wallet&.amount + exchange_result)
    end
  end
end
