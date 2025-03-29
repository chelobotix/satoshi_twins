module ExchangeModule
  class ExchangeValidations
    include ResultUtils::Builder

    CRYPTO_LIST = %w[bitcoin].freeze
    CURRENCY_LIST = %w[usd].freeze
    private_constant :CRYPTO_LIST
    private_constant :CURRENCY_LIST

    def initialize(exchange_rate:, amount:, source_crypto:, target_crypto:, user:)
      @exchange_rate = exchange_rate
      @amount = amount
      @source_crypto = source_crypto
      @target_crypto = target_crypto
      @user = user
      @source_wallet = nil
      @target_wallet = nil
      @errors = []
    end

    def call
      handle_validations

      if @errors.any?
        failure(data: { status: "failed", error: @errors.join(",") })
      else
        success(data: { status: "success", data: { source_wallet: @source_wallet, target_wallet: @target_wallet } })
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

      validate_user
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

    def validate_user
      if @user != @source_wallet&.user || @user != @target_wallet&.user
        @errors << I18n.t("exchange.invalid_user")
      end
    end

    def validate_amount
      if @source_wallet&.amount < @amount
        @errors << I18n.t("exchange.insufficient_funds", available: @source_wallet&.amount)
      end
    end
  end
end
