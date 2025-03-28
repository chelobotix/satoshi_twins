class CustomRegistrationsController < DeviseTokenAuth::RegistrationsController
  def render_create_success
    # Call service to create welcome wallets
    result = OnBoardingService.new(@resource).call

    if result.success?
      super
    else
      render(json: { errors: result.error }, status: :unprocessable_entity)
    end
  end
end
