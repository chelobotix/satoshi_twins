require 'swagger_helper'

RSpec.describe 'Wallets API', type: :request do
  path '/api/v1/users/{user_id}/wallets' do
    get 'List all wallets for the user' do
      tags 'Wallets'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :user_id, in: :path, type: :integer, required: true, description: 'User ID'

      response '200', 'wallets found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let!(:wallets) { create_list(:wallet, 3, user: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['data'].length).to eq(3)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:user_id) { 1 }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/wallets/{id}' do
    get 'Get a specific wallet' do
      tags 'Wallets'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :user_id, in: :path, type: :integer, required: true, description: 'User ID'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Wallet ID'

      response '200', 'wallet found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let(:wallet) { create(:wallet, user: user) }
        let(:id) { wallet.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['id']).to eq(wallet.id)
          expect(data['data']['amount']).to be_present
          expect(data['data']['currency']).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:user_id) { 1 }
        let(:id) { 1 }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'wallet not found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let(:id) { 999 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
