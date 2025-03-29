class Api::V1::WalletsController < ApplicationController
  def index
    wallets = Wallet.where(user: current_user)
    render(json: wallets, include: %w[currency], status: :ok)
  end
end
