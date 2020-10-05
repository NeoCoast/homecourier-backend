require 'rails_helper'

RSpec.describe "Api::V1::Helpees", type: :request do

  let!(:helpees) { create_list(:user, 10, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  describe "GET /api/v1/helpees" do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before(:each) do
      post api_v1_users_path + "/login", params: { user: {
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
              "id", "email", "username", "name", "lastname", "birth_date", "address")
        end
        expect(@body).to match_array(helpees_array)
      end
    end
  end
end