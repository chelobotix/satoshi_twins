require 'swagger_helper'

RSpec.describe 'Wallet Exchanges API', type: :request do
  path '/api/v1/users/{user_id}/wallet_exchanges' do
    get 'List all wallet exchanges for the user' do
      tags 'Wallet Exchanges'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :user_id, in: :path, type: :integer, required: true, description: 'User ID'

      response '200', 'exchanges found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
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

  path '/api/v1/users/{user_id}/wallet_exchanges/{id}' do
    get 'Get a specific wallet exchange' do
      tags 'Wallet Exchanges'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :user_id, in: :path, type: :integer, required: true, description: 'User ID'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Exchange ID'

      response '200', 'exchange found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let(:wallet_exchange) { create(:wallet_exchange, user: user) }
        let(:id) { wallet_exchange.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['id']).to eq(wallet_exchange.id)
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

      response '404', 'exchange not found' do
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

  path '/api/v1/users/{user_id}/wallet_exchanges' do
    post 'Create a new wallet exchange' do
      tags 'Wallet Exchanges'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :user_id, in: :path, type: :integer, required: true, description: 'User ID'
      parameter name: :exchange, in: :body, schema: {
        type: :object,
        properties: {
          exchange: {
            type: :object,
            properties: {
              amount: { type: :number, example: 1.5 },
              source_coin: { type: :string, example: 'bitcoin' },
              target_coin: { type: :string, example: 'usd' }
            },
            required: %w[amount source_coin target_coin]
          }
        }
      }

      response '200', 'exchange created' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let(:exchange) do
          {
            exchange: {
              amount: 1.5,
              source_coin: 'bitcoin',
              target_coin: 'usd'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_present
          expect(data['data']['amount']).to eq('1.5')
        end
      end

      response '400', 'invalid parameters' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:user_id) { user.id }
        let(:exchange) do
          {
            exchange: {
              amount: -1,
              source_coin: 'invalid',
              target_coin: 'usd'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('failed')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:user_id) { 1 }
        let(:exchange) do
          {
            exchange: {
              amount: 1.5,
              source_coin: 'bitcoin',
              target_coin: 'usd'
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
