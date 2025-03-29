FactoryBot.define do
  factory :wallet_exchange do
    user
    exchange
    source_wallet { create(:wallet) }
    target_wallet { create(:wallet) }
    source_wallet_amount_before { 1.0 }
    source_wallet_amount_after { 0.9 }
    target_wallet_amount_before { 1000.0 }
    target_wallet_amount_after { 6000.0 }
  end
end
