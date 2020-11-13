# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::SessionsController', type: :request do
  let!(:user_vol) do
    create(
      :user,
      type: 'Volunteer',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
      enabled: true
    )
  end
  let!(:user_helpee) do
    create(
      :user,
      type: 'Helpee',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end

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

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns authorization token' do
          expect(response.headers['Authorization']).to include('Bearer')
        end
      end
      context 'Helpee' do
        subject do
          {
            email: user_helpee.email,
            password: user_helpee.password
          }
        end

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns authorization token' do
          expect(response.headers['Authorization']).to include('Bearer')
        end
      end
    end
    context 'fails' do
      context 'Volunteer' do
        let!(:volunteer_not_enabled) do
          create(
            :user,
            type: 'Volunteer',
            confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today),
            enabled: false
          )
        end
        subject do
          {
            email: volunteer_not_enabled.email,
            password: volunteer_not_enabled.password
          }
        end

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
      context 'Helpee' do
        let!(:unregistered_user) { build(:user, type: 'Helpee') }
        subject do
          {
            email: unregistered_user.email,
            password: unregistered_user.password
          }
        end

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns error message' do
          expect(response.body).to include('error')
          expect(response.body).to include('Invalid Email or password')
        end
      end
    end
  end

  describe 'DELETE /api/v1/users/logout' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'succeeds' do
      context 'Volunteer' do
        subject do
          {
            email: user_vol.email,
            password: user_vol.password
          }
        end

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
          @token = response.headers['Authorization']
        end

        it 'returns http success' do
          delete api_v1_users_path + '/logout',
                 headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          expect(response).to have_http_status(:ok)
        end

        it 'session expired' do
          delete api_v1_users_path + '/logout',
                 headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          get api_v1_users_path,
              headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'Helpee' do
        subject do
          {
            email: user_helpee.email,
            password: user_helpee.password
          }
        end

        before(:each) do
          post api_v1_users_path + '/login',
               params: { user: subject },
               headers: headers
          @token = response.headers['Authorization']
        end

        it 'returns http success' do
          delete api_v1_users_path + '/logout',
                 headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          expect(response).to have_http_status(:ok)
        end

        it 'session expired' do
          delete api_v1_users_path + '/logout',
                 headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          get api_v1_users_path,
              headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
