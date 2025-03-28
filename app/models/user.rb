# frozen_string_literal: true

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  after_create :on_boarding

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Relationships
  has_many :wallets

  private

  def on_boarding
    OnBoardingService.new(self).call
    Rails.logger.error("☢️ >>>>>-----> welcome wallets created for user #{email}")
  end
end
