require "bigdecimal"

module CurrencyFormat
  extend ActionView::Helpers::NumberHelper

  def self.format(amount: 0, precision: 2)
    number_with_precision(amount, delimiter: ".", separator: ",", precision:)
  end

  def self.crypto_format(amount: 0, precision: 8)
    number_with_precision(amount, delimiter: ".", separator: ",", precision:)
  end

  def self.to_big_decimal(amount)
    cleaned_amount = amount.gsub(".", "").gsub(",", ".")
    BigDecimal(cleaned_amount)
  end
end
