require 'rails_helper'

RSpec.describe 'Api::V1::Devise::PasswordsController', type: :request do

  let!(:headers) { { 'ACCEPT' => 'application/json' } }
  let!(:user_vol) { create(:user, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:user_helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  describe 'POST /api/v1/users/password' do
    context 'succeeds' do
      context 'Volunteer' do
        subject do
          {
              email: user_vol.email
          }
        end

        before(:each) do
          post api_v1_users_path + "/password", params: { user: subject }, headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'Helpee' do
        subject do
          {
              email: user_helpee.email
          }
        end

        before(:each) do
          post api_v1_users_path + "/password", params: { user: subject }, headers: headers
        end

        it 'returns http success' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'fails' do

      context 'email is empty' do
        subject do
          {
              email: nil
          }
        end

        before(:each) do
          post api_v1_users_path + "/password", params: { user: subject }, headers: headers
        end

        it 'returns http unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error message: email can't be blank" do
          expect(response.body).to include("can't be blank")
        end
      end

      context 'email not exists in db' do
        subject do
          {
              email: Faker::Internet.email
          }
        end

        before(:each) do
          post api_v1_users_path + "/password", params: { user: subject }, headers: headers
        end

        it 'returns http unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message: email not found' do
          expect(response.body).to include("not found")
        end
      end
    end
  end
end