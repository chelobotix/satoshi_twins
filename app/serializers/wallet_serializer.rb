class WalletSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :currency
end
