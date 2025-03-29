FactoryBot.define do
  factory :exchange do
    send_amount { 0.1 }
    receive_amount { 5000.0 }
    exchange_rate { 50000.0 }
    aasm_state { "processing" }
    send_currency { create(:currency, :bitcoin) }
    receive_currency { create(:currency, :usd) }
  end
end
