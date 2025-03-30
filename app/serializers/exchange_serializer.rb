class ExchangeSerializer < ActiveModel::Serializer
  attributes :id,
             :send_amount,
             :receive_amount,
             :exchange_rate,
             :aasm_state,
             :send_currency_id,
             :receive_currency_id,
             :created_at

  def send_amount
    CurrencyFormat.crypto_format(amount: object.send_amount)
  end

  def receive_amount
    CurrencyFormat.format(amount: object.receive_amount)
  end

  def exchange_rate
    CurrencyFormat.format(amount: object.exchange_rate)
  end
end
