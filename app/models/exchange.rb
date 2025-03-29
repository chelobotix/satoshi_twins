class Exchange < ApplicationRecord
  # Relationships
  has_many :wallet_exchanges, dependent: :destroy
  has_many :wallets, through: :wallet_exchanges

  # Validations
  validates :send_amount, presence: true, numericality: { greater_than: 0 }
  validates :receive_amount, presence: true, numericality: { greater_than: 0 }

  aasm do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed

    event :process do
      transitions from: :pending, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: [ :pending, :processing ], to: :failed
    end
  end
end
