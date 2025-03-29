class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :currency
  has_many :source_exchanges, class_name: "WalletExchange", foreign_key: "source_wallet_id"
  has_many :exchanges_as_source, through: :source_exchanges, source: :exchange
  has_many :target_exchanges, class_name: "WalletExchange", foreign_key: "target_wallet_id"
  has_many :exchanges_as_target, through: :target_exchanges, source: :exchange

  # Validations
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
