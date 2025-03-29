FactoryBot.define do
  factory :wallet do
    user
    currency
    amount { 0.0 }
  end
end
