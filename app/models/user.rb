# frozen_string_literal: true

class User < ActiveRecord::Base
  # after_create :on_boarding

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Relationships
  has_many :wallets, dependent: :destroy
  has_many :wallet_exchanges, dependent: :destroy

  include DeviseTokenAuth::Concerns::User

  private

  def on_boarding
    OnBoardingService.new(self).call
    Rails.logger.error("☢️ >>>>>-----> welcome wallets created for user #{email}")
  end
end
