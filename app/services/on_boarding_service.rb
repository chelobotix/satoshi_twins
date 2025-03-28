class OnBoardingService
  INITIAL_CURRENCIES = {
    bitcoin: 0.98765432,
    usd: 1000.00
  }.freeze
  private_constant :INITIAL_CURRENCIES

  def initialize(user)
    @user = user
  end

  def call
    handle_welcome_wallets
  end

  private

  def handle_welcome_wallets
    ApplicationRecord.transaction do
      INITIAL_CURRENCIES.each do |currency_name, amount|
        create_wallet(currency_name, amount)
      end
    end

  rescue ActiveRecord::RecordInvalid  => e
    add_error_log("Wallet: #{e.message }")
    raise ActiveRecord::Rollback
  rescue ActiveRecord::RecordNotFound=> e
    add_error_log("Record not found: #{e.message }")
    raise ActiveRecord::Rollback
  rescue ActiveRecord::RecordInvalid => e
    add_error_log("Record invalid: #{e.message }")
    raise ActiveRecord::Rollback
  rescue StandardError => e
    add_error_log("Can not complete the registration: #{e.message }")
    raise ActiveRecord::Rollback
  end

  def create_wallet(currency_name, amount)
    currency = Currency.find_by!(name: currency_name)
    Wallet.create!(user: @user, currency: currency, amount: amount)
  end

  def add_error_log(message)
    Rails.logger.error("⚠️ >>>>>-----> #{message}\n")
  end
end
