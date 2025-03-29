class ExchangeSerializer < ActiveModel::Serializer
  attributes :id,
             :send_amount,
             :receive_amount,
             :exchange_rate,
             :aasm_state,
             :send_currency_id,
             :receive_currency_id,
             :created_at
end
