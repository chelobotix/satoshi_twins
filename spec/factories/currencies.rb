FactoryBot.define do
  factory :currency do
    sequence(:name) { |n| "currency_#{n}" }
    sequence(:symbol) { |n| "CUR#{n}" }

    trait :bitcoin do
      name { "bitcoin" }
      symbol { "BTC" }
    end

    trait :usd do
      name { "usd" }
      symbol { "USD" }
    end
  end
end
