class WalletExchange < ApplicationRecord
  belongs_to :exchange
  belongs_to :wallet
end
