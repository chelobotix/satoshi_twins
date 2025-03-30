module Coingecko
  class CoingeckoService
    include ResultUtils::Builder

    CRYPTO_LIST = %w[bitcoin].freeze
    CURRENCY_LIST = %w[usd].freeze
    private_constant :CRYPTO_LIST
    private_constant :CURRENCY_LIST

    def initialize(crypto_currency_name, target_currency_name)
      validate_params!(crypto_currency_name, target_currency_name)

      @crypto_currency_name = crypto_currency_name.split(",")
      @target_currency_name = target_currency_name.split(",")
    end

    def call
      validations

      get_market_data
    end

    private

    def validations
      return failure(data: { status: "failed", details: I18n.t("invalid_params") }) unless valid_params?

      unless is_currency_allowed?
        failure(data: { status: "failed", details: I18n.t(
          "exchange.invalid_currencies",
          allowed: (CRYPTO_LIST + CURRENCY_LIST).join(", ")) }
        )
      end
    end

    def get_market_data
      handle_request
    end

    def handle_request
      base_url = ENV["COINGECKO_BASE_URL"]
      api_key = ENV["COINGECKO_API_KEY"]

      headers = create_headers(api_key)
      cryptos = join_currencies(:crypto)
      targets = join_currencies(:currency)

      uri = URI("#{base_url}/simple/price?ids=#{cryptos}&vs_currencies=#{targets}&&precision=4&include_last_updated_at=true")

      make_request(uri, headers)
    end

    def create_headers(api_key)
      {
        Accept: "application/json",
        'x-cg-demo-api-key': api_key
      }
    end

    def make_request(uri, headers)
      response = HTTParty.get(
        uri,
        headers: headers,
        timeout: 30,
        open_timeout: 10,
        read_timeout: 20,
        write_timeout: 20,
        retry_base_delay: 1,
        retry_max_delay: 10,
        retry_max_count: 3
      )

      if response.code == 200 && !(response.body.nil? || response.body.empty?)
        handle_response(response.body)
      else
        failure(data: { status: "failed", error: I18n.t("coingecko.error_response"), details: response.body })
      end
    end

    def handle_response(response)
      begin
        prices = JSON.parse(response).with_indifferent_access
      rescue JSON::ParserError
        failure(data: { status: "failed", error: I18n.t("coingecko.invalid_response") })
      end

      format_price(prices)

      success(data: { status: "success", data: { prices: [ prices ] } })
    end

    def format_price(prices)
      prices.each do |key, value|
        if key == "bitcoin" && prices[:bitcoin].key?(:usd)
          prices[:bitcoin][:usd] = CurrencyFormat.format(amount: prices[:bitcoin][:usd], precision: 2)
        end
      end
    end

    def is_currency_allowed?
      crypto_exists = @crypto_currency_name.all? { |element| CRYPTO_LIST.include?(element) }
      currency_exists = @target_currency_name.all? { |element| CURRENCY_LIST.include?(element) }

     crypto_exists && currency_exists
    end

    def join_currencies(type)
      if type == :crypto
        @crypto_currency_name.join(",")
      elsif type == :currency
        @target_currency_name.join(",")
      end
    end

    def valid_params?(crypto_currency_name, target_currency_name)
      crypto_currency_name.present? && target_currency_name.present?
    end
  end
end
