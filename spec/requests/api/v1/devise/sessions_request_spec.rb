# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::SessionsController', type: :request do
require 'rails_helper'

RSpec.describe 'Api::V1::Devise::SessionsController', type: :request do

  let!(:user_vol) { create(:user, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:user_helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:unregistered_user) { build(:user, type: 'Helpee') }

  describe 'POST /api/v1/users/login' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'succeeds' do
      context 'Volunteer' do
        subject do
          {
              email: user_vol.email,
              password: user_vol.password
          }
        end

        before(:each) { post api_v1_users_path + "/login", params: { user: subject }, headers: headers }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns authorization token' do
          expect(response.headers["Authorization"]).to include("Bearer")
        end
      end
      context 'Helpee' do
        subject do
          {
              email: user_helpee.email,
              password: user_helpee.password
          }
        end

        before(:each) { post api_v1_users_path + "/login", params: { user: subject }, headers: headers }

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns authorization token' do
          expect(response.headers["Authorization"]).to include("Bearer")
        end
      end
    end
    context 'fails' do
      subject do
        {
            email: unregistered_user.email,
            password: unregistered_user.password
        }
      end

      before(:each) { post api_v1_users_path + "/login", params: { user: subject }, headers: headers }

      it 'returns http bad_request' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        expect(response.body).to include("error")
        expect(response.body).to include("Invalid Email or password")
      end
    end
  end
end
