# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::ConfirmationsController', type: :request do
  let!(:user_vol) { create(:user, type: 'Volunteer') }
  let!(:user_helpee) { create(:user, type: 'Helpee') }

  describe 'GET /api/v1/users/confirmation' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'succeeds' do
      context 'Volunteer' do
        before(:each) do
          get api_v1_users_path + '/confirmation?confirmation_token=' + user_vol.confirmation_token,
              headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'confirmation date is set' do
          expect(User.find(user_vol.id).confirmed_at).to_not be_nil
        end
      end
      context 'Helpee' do
        before(:each) do
          get api_v1_users_path + '/confirmation?confirmation_token=' + user_helpee.confirmation_token,
              headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end

        it 'confirmation date is set' do
          expect(User.find(user_helpee.id).confirmed_at).to_not be_nil
        end
      end
    end
    context 'fails' do
      before(:each) do
        get api_v1_users_path + '/confirmation?confirmation_token=' + Faker::Internet.password(min_length: 20),
            headers: headers
      end

      it 'returns http unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'confirmation_token is invalid' do
        @body = JSON.parse(response.body)
        expect(@body).to_not be_nil
        expect(@body['confirmation_token']).to eq(['is invalid'])
      end
    end
  end
end
