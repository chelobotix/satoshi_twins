require 'swagger_helper'

RSpec.describe 'Crypto Price Tracker API', type: :request do
  path '/api/v1/crypto_price_tracker' do
    get 'Get the cryptocurrency actual price' do
      tags 'Crypto Price Tracker'
      produces 'application/json'
      security [ { bearer_auth: [] } ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Token'
      parameter name: :source_coin, in: :query, type: :string, required: true, description: 'Source coin (ex: bitcoin)'
      parameter name: :target_coin, in: :query, type: :string, required: true, description: 'Target coin (ex: usd)'

      response '200', 'price found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:source_coin) { 'bitcoin' }
        let(:target_coin) { 'usd' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['prices']).to be_an(Array)
          expect(data['data']['prices'][0]['bitcoin']['usd']).to be_present
        end
      end

      response '401', 'no authorized' do
        let(:Authorization) { nil }
        let(:source_coin) { 'bitcoin' }
        let(:target_coin) { 'usd' }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '400', 'invalid parameters' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:source_coin) { 'invalid' }
        let(:target_coin) { 'usd' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('failed')
          expect(data['details']).to eq('Invalid currency')
        end
      end

      response '400', 'missing parameters' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:source_coin) { nil }
        let(:target_coin) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
