class Api::V1::CryptoPriceTrackerController < ApplicationController
  def index
    coingecko_service = Coingecko::CoingeckoService.new(params[:source_coin], params[:target_coin]).call

    if coingecko_service.success?
      render(json: coingecko_service.data, status: :ok)
    else
      render(json: coingecko_service.error, status: :bad_request)
    end
  end
end
