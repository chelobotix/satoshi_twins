class Api::V1::CryptoPriceTrackerController < ApplicationController
  def index
    begin
      coingecko_service = Coingecko::CoingeckoService.new(
        params[:source_coin],
        params[:target_coin]
      )
      result = coingecko_service.call
    rescue ArgumentError => e
      return render(json: { status: "fail", error: e.message }, status: :bad_request)
    end


    if result.success?
      render(json: result.data, status: :ok)
    else
      render(json: result.error, status: :bad_request)
    end
  end
end
