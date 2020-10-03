# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::SessionsController', type: :request do
  describe 'POST /api/v1/users/login' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }
    let!(:volunteer_params) do
      { email: 'test@test.com', password: '123456', username: 'test',
        name: 'name', lastname: 'lastname', birth_date: '1/1/2000', address: '1st Street',
        document_number: '1.234.567-8', document_type_id: '1', confirmed_at: '1900-01-02 01:01:01.000001' }
    end

    before do
      Volunteer.create(volunteer_params)
    end

    it 'returns http success' do
      post '/api/v1/users/login', params: { user: { email: 'test@test.com', password: '123456' } }, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end
end