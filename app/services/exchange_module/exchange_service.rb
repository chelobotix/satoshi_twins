module ExchangeModule
  class ExchangeService
    include ResultUtils::Builder

    CRYPTO_LIST = %w[bitcoin].freeze
    CURRENCY_LIST = %w[usd].freeze
    private_constant :CRYPTO_LIST
    private_constant :CURRENCY_LIST

    def initialize(exchange_rate:, amount:, source_crypto:, target_crypto:, user:)
      validate_params!(exchange_rate, amount, source_crypto, target_crypto)

      @exchange_rate = find_exchange_rate(exchange_rate, source_crypto, target_crypto)
      @amount = amount
      @source_crypto = Currency.find_by(name: source_crypto)
      @target_crypto = Currency.find_by(name: target_crypto)
      @user = user
      @errors = []
      @source_wallet = nil
      @target_wallet = nil
      @exchange = nil
      @wallet_exchange = nil
    end

    def call
      handle_validations
      failure(data: { status: "failed", error: @errors.join(",") }) if @errors.any?

      handle_exchange
      if @errors.any? || @wallet_exchange.blank?
        failure(data: { status: "failed", error: @errors.join(",") })
      else
        success(data: { status: "success", wallet_exchange: @wallet_exchange })
      end
    end

    private

    def handle_validations
      validate_exchange_rate
      return if @errors.any?

      validate_currencies
      return if @errors.any?

      validate_wallets
      return if @errors.any?

      validate_amount
    end

    def validate_exchange_rate
      @errors << I18n.t("exchange.invalid_exchange_rate") if @exchange_rate.blank?
    end

    def validate_currencies
      unless CRYPTO_LIST.include?(@source_crypto.name) && CURRENCY_LIST.include?(@target_crypto.name)
        @errors << I18n.t("exchange.invalid_currencies", allowed: (CRYPTO_LIST + CURRENCY_LIST).join(", "))
      end
    end

    def validate_wallets
      find_wallets

      @errors << I18n.t("exchange.wallet_not_found") if @source_wallet.blank? || @target_wallet.blank?
    end

    def find_wallets
      @user.wallets.each do |wallet|
        next unless [ @source_crypto.name, @target_crypto.name ].include?(wallet.currency.name)

        if wallet.currency.name == @source_crypto.name
          @source_wallet = wallet
        elsif wallet.currency.name == @target_crypto.name
          @target_wallet = wallet
        end
      end
    end

    def validate_amount
      if @source_wallet&.amount < @amount
        @errors << I18n.t("exchange.insufficient_funds", available: @source_wallet&.amount)
      end
    end

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

    def find_exchange_rate(exchange_rate, source_crypto, target_crypto)
      rate = exchange_rate.find do |item|
        item.key?(source_crypto) && item[source_crypto].key?(target_crypto)
      end

      CurrencyFormat.to_big_decimal(rate[source_crypto][target_crypto]) if rate.present?
    end

    def validate_params!(exchange_rate, amount, source_crypto, target_crypto)
      raise ArgumentError, I18n.t("exchange.miss_source_crypto") if source_crypto.blank?
      raise ArgumentError, I18n.t("exchange.miss_target_crypto") if target_crypto.blank?
      raise ArgumentError, I18n.t("exchange.negative_amount") if amount.blank? || amount.to_f <= 0
      raise ArgumentError, I18n.t("exchange.no_rate_found") if exchange_rate.blank?
    end
  end
end
