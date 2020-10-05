require 'rails_helper'

RSpec.describe "Api::V1::Volunteers", type: :request do

  let!(:volunteers) { create_list(:volunteer, 10, confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  describe "GET /api/v1/volunteers" do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteers[0].email, password: volunteers[0].password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_volunteers_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do

      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq volunteers.length
      end

      it 'content of records' do
        volunteers_array = []
        volunteers.each do |volunteer|
          volunteers_array << volunteer.attributes.slice(
              "id", "email", "username", "name", "lastname", "birth_date", "address", "document_type_id", "document_number")
        end
        expect(@body).to match_array(volunteers_array)
      end
    end
  end
end