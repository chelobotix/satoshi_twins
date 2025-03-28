class RegistrationSuccessController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    # TODO: Add real documentation path on view
    @result = params[:account_confirmation_success]
  end
end
