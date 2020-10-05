require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do

  let!(:volunteer_users) { create_list(:user, 10, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:helpee_users) { create_list(:user, 10, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  describe "GET /api/v1/users" do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer_users[0].email, password: volunteer_users[0].password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_users_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do

      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq(volunteer_users.length + helpee_users.length)
      end

      it 'content of records' do
        users = []
        volunteer_users.each do |volunteer_user|
          users << volunteer_user.attributes.slice("id", "email", "username", "name", "lastname", "birth_date", "address")
        end
        helpee_users.each do |helpee_user|
          users << helpee_user.attributes.slice("id", "email", "username", "name", "lastname", "birth_date", "address")
        end
        expect(@body).to match_array(users)
      end
    end
  end
end