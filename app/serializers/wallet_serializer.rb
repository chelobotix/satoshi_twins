class WalletSerializer < ActiveModel::Serializer
  attributes :id, :amount, :created_at, :updated_at

  def amount
    if object.currency.name == "bitcoin"
      CurrencyFormat.crypto_format(amount: object.amount)
    else
      CurrencyFormat.format(amount: object.amount)
    end
  end

  belongs_to :currency
  belongs_to :user
end
