class Wallet < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :currency

  # Validations
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
