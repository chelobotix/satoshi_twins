class WalletExchangeSerializer < ActiveModel::Serializer
  attributes :id,
             :source_wallet_amount_before,
             :source_wallet_amount_after,
             :target_wallet_amount_before,
             :target_wallet_amount_after,
             :created_at

  def source_wallet_amount_before
    CurrencyFormat.crypto_format(amount: object.source_wallet_amount_before)
  end

  def source_wallet_amount_after
    CurrencyFormat.crypto_format(amount: object.source_wallet_amount_after)
  end

  def target_wallet_amount_before
    CurrencyFormat.format(amount: object.target_wallet_amount_before)
  end

  def target_wallet_amount_after
    CurrencyFormat.format(amount: object.target_wallet_amount_after)
  end

  belongs_to :exchange
  belongs_to :source_wallet, class_name: "Wallet"
  belongs_to :target_wallet, class_name: "Wallet"
end
