require 'rails_helper'

RSpec.describe "Api::V1::DocumentTypes", type: :request do

  let!(:user_vol) { create(:user, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:document_types) { create_list(:document_type, 10) }

  describe "GET /api/v1/document_types" do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'Volunteer' do
      subject do
        {
            email: user_vol.email,
            password: user_vol.password
        }
      end

      before(:each) do
        post api_v1_users_path + "/login", params: { user: subject }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_document_types_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      context 'the answer matches db' do

        before(:each) { @body = JSON.parse(response.body) }

        it 'number of records' do
          expect(@body.length).to eq document_types.length
        end

        it 'content of records' do
          document_types_array = []
          document_types.each do |document_type|
            document_types_array << document_type.attributes.slice("id", "description")
          end
          expect(@body).to match_array(document_types_array)
        end
      end
    end
  end
end