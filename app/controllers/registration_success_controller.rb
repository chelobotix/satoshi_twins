class RegistrationSuccessController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @result = params[:account_confirmation_success]
  end
end
