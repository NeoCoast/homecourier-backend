require 'rails_helper'

RSpec.describe 'Api::V1::Helpees', type: :request do
  let!(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/helpees' do
    let!(:helpees) do
      create_list(:user, 10, type: 'Helpee',
                             confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today))
    end

    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: helpees[0].email, password: helpees[0].password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_helpees_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do
      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq helpees.length
      end

      it 'content of records' do
        helpees_array = []
        helpees.each do |helpee|
          helpees_array << helpee.attributes.slice(
            'id', 'email', 'username', 'name', 'lastname', 'birth_date', 'address'
          )
        end
        expect(@body).to match_array(helpees_array)
      end
    end
  end

  describe 'GET /api/v1/helpees/:id' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

    context 'shows helpee' do
      before do
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_helpees_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      context 'returns correct user data' do
        before do
          get api_v1_helpees_path + '/' + helpee.id.to_s, headers: { 'ACCEPT' => 'application/json',
                                                                     'HTTP_AUTHORIZATION' => @token }
          @body = JSON.parse(response.body)
        end

        it 'succeeds' do
          expect(@body['id']).to eq helpee.id
        end
      end
    end
  end
end
