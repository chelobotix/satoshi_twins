module ExchangeModule
  class ExchangeService
    include ResultUtils::Builder

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
      validations = ExchangeValidations.new(
        exchange_rate: @exchange_rate,
        amount: @amount,
        source_crypto: @source_crypto,
        target_crypto: @target_crypto,
        user: @user
      ).call

      if validations.success?
        @source_wallet = validations.data[:data][:source_wallet]
        @target_wallet = validations.data[:data][:target_wallet]
      else
        @errors << validations.error[:error]
      end
    end

    def handle_exchange
      exchange_sync = ExchangeSync.new(
        exchange_rate: @exchange_rate,
        amount: @amount,
        source_crypto: @source_crypto,
        target_crypto: @target_crypto,
        user: @user,
        source_wallet: @source_wallet,
        target_wallet: @target_wallet
      ).call

      if exchange_sync.success?
        @wallet_exchange = exchange_sync.data[:wallet_exchange]
      else
        @errors << exchange_sync.error[:error]
      end
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
