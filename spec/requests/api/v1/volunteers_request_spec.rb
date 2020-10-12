require 'rails_helper'

RSpec.describe 'Api::V1::Volunteers', type: :request do
  let!(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/volunteers' do
    let!(:volunteers) { create_list(:volunteer, 10, confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
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
            'id', 'email', 'username', 'name', 'lastname', 'birth_date', 'address', 'document_type_id', 'document_number'
          )
        end
        expect(@body).to match_array(volunteers_array)
      end
    end
  end

  describe 'GET /api/v1/helpees/:id' do
    let!(:volunteer) { create(:user, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

    context 'shows volunteer' do
      before do
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_volunteers_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      context 'returns correct user data' do
        before do
          get api_v1_volunteers_path + '/' + volunteer.id.to_s, headers: { 'ACCEPT' => 'application/json',
                                                                           'HTTP_AUTHORIZATION' => @token }
          @body = JSON.parse(response.body)
        end

        it 'succeeds' do
          expect(@body['id']).to eq volunteer.id
        end
      end
    end
  end
end
