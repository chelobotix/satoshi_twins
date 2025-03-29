class Api::V1::WalletExchangesController < ApplicationController
  def index
  end

  def create
    begin
      coingecko_service = Coingecko::CoingeckoService.new(
        params[:exchange][:source_coin],
        params[:exchange][:target_coin]
      )
      coingecko_result = coingecko_service.call
    rescue ArgumentError => e
      return render(json: { status: "fail", error: e.message }, status: :bad_request)
    end


    if coingecko_result.success?
      begin
        exchange_service = ExchangeModule::ExchangeService.new(
          exchange_rate: coingecko_result.data[:data][:prices],
          amount: params[:exchange][:amount],
          source_crypto: params[:exchange][:source_coin],
          target_crypto: params[:exchange][:target_coin],
          user: current_user
        )
      rescue ArgumentError => e
        return render(json: { status: "fail", error: e.message }, status: :bad_request)
      end

      result = exchange_service.call

      if result.success?
        render(json: result.data[:wallet_exchange], include: %w[source_wallet.currency target_wallet.currency exchange], status: :ok)
      else
        render(json: result.error, status: :bad_request)
      end

    else
      render(json: coingecko_result.error, status: :bad_request)
    end
  end
end
