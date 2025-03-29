class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :currency
  has_many :wallet_exchanges, dependent: :destroy
  has_many :exchanges, through: :wallet_exchanges

  # Validations
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
