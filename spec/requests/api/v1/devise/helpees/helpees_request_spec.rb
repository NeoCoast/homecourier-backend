# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::Helpees::RegistrationsController', type: :request do
  let!(:user) { build :user }

  describe 'POST /api/v1/helpees/signup' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    subject do
      {
        email: user.email,
        password: user.password,
        username: user.username,
        name: user.name,
        lastname: user.lastname,
        birth_date: user.birth_date,
        address: user.address
      }
    end

    context 'succeeds' do
      before do
        post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:created)
      end

      it 'creates an user' do
        expect(User.count).to eq 1
      end
    end

    context 'fails' do
      context 'email is empty' do
        before do
          subject['email'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'password is empty' do
        before do
          subject['password'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'username is empty' do
        before do
          subject['username'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'name is empty' do
        before do
          subject['name'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'lastname is empty' do
        before do
          subject['lastname'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'birth date is empty' do
        before do
          subject['birth_date'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'address is empty' do
        before do
          subject['address'] = nil
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end

      context 'user is underaged' do
        before do
          day = Date.tomorrow.day
          month = Date.today.month
          year = Date.today.year

          subject['birth_date'] = "#{day}/#{month}/#{year}"
          post api_v1_helpees_path + '/signup', params: { helpee: subject }, headers: headers
        end

        it 'returns http bad_request' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'is not created' do
          expect(User.count).to_not eq 1
        end
      end
    end
  end
end
