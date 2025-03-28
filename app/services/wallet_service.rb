class WalletService
  include ResultUtils::Builder

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def create(amount)
    wallet = Wallet.new(user_id: @user.id, currency_id: @currency.id, amount: 0)
  end

  private
end
