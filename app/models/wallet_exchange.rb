class WalletExchange < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :exchange
  belongs_to :source_wallet, class_name: "Wallet"
  belongs_to :target_wallet, class_name: "Wallet"

  # Validations
  validates :exchange_id, uniqueness: { scope: [ :source_wallet_id, :target_wallet_id ] }
end
