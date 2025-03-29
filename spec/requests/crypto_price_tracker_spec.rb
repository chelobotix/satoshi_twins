require 'rails_helper'

RSpec.describe "CryptoPriceTrackers", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get "/crypto_price_tracker/index"
      expect(response).to have_http_status(:success)
    end
  end
end
