class OnBoardingService
  def initialize(user)
    @user = user
  end

  def call
    create_models
  end

  private

  def create_models
    puts "Creating models for user: #{@user.email}"
  end
end
