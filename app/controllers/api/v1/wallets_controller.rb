class Api::V1::WalletsController < ApplicationController
  def index
    wallets = Wallet.where(user: current_user)
    render(json: wallets, include: %w[currency user], status: :ok)
  end

  def show
    wallet = Wallet.find_by(id: params[:id], user: current_user)
    render(json: wallet, include: %w[currency user], status: :ok)
  end

  # TODO: Create new wallets V.2
  def create
  end

  # TODO: Update wallets V.2
  def update
  end

  # TODO: Destroy wallets V.2
  def delete
  end
end
