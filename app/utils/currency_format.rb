module CurrencyFormat
  extend ActionView::Helpers::NumberHelper

  def self.format(amount: 0, precision: 2)
    number_with_precision(amount, delimiter: ".", separator: ",", precision:)
  end
end
