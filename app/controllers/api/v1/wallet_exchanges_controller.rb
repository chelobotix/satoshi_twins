class Api::V1::WalletExchangesController < ApplicationController
  def index
    wallet_exchanges = WalletExchange.where(user_id: current_user.id)

    serializer(wallet_exchanges)
  end

  def show
    wallet_exchange = WalletExchange.find_by(id: params[:id], user_id: current_user.id)

    serializer(wallet_exchange)
  end

  def create
    coingecko_result = get_rate_from_coingecko

    if coingecko_result&.success?
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
        serializer(result.data[:wallet_exchange])
      else
        render(json: result.error, status: :bad_request)
      end

    else
      render(json: coingecko_result&.error, status: :bad_request)
    end
  end

  private

  def get_rate_from_coingecko
    Coingecko::CoingeckoService.new(
      params[:exchange][:source_coin],
      params[:exchange][:target_coin]
    ).call
  end

  def serializer(record)
    serialized_data = ActiveModelSerializers::SerializableResource.new(
      record,
      include: %w[user exchange source_wallet.currency target_wallet.currency]
    ).as_json

    render json: { data: serialized_data }, status: :ok
  end
end
