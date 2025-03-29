class WalletSerializer < ActiveModel::Serializer
  attributes :id, :amount, :created_at, :updated_at



  belongs_to :currency
  belongs_to :user
end
