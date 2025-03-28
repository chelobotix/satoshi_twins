class OnBoardingService
  include ResultUtils::Builder

  INITIAL_CURRENCIES = {
    bitcoin: 0.98765432,
    usd: 1000.00
  }.freeze
  private_constant :INITIAL_CURRENCIES

  def initialize(user)
    @user = user
    @error = false
  end

  def call
    handle_welcome_wallets

    if @error
      failure(data: { status: "failed", details: "Error creating welcome wallets" })
    else
      success(data: { status: "success", details: "Welcome wallets created" })
    end
  end

  private

  def handle_welcome_wallets
    ApplicationRecord.transaction do
      INITIAL_CURRENCIES.each do |currency_name, amount|
        create_wallet(currency_name, amount)
      end
    end

  rescue ActiveRecord::RecordInvalid  => e
    handle_error("Wallet: #{e.message }")
  rescue ActiveRecord::RecordNotFound=> e
    handle_error("Record not found: #{e.message }")
  rescue ActiveRecord::RecordInvalid => e
    handle_error("Record invalid: #{e.message }")
  rescue StandardError => e
    handle_error("Can not complete the registration: #{e.message }")
  end

  def create_wallet(currency_name, amount)
    currency = Currency.find_by(name: currency_name)

    Wallet.create!(user: @user, currency:, amount:)
  end

  def add_error_log(message)
    Rails.logger.error("⚠️ >>>>>-----> #{message}\n")
  end

  def handle_error(message)
    add_error_log(message)
    @user.destroy
    @error = true
  end
end
