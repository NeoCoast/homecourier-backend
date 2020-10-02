# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Devise::Volunteers::RegistrationsController', type: :request do
  describe 'POST /api/v1/helpees/signup' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before do
      post '/api/v1/volunteers/signup', params: { volunteer: { email: 'volunteer@mail.com', password: '123456',
                                                               username: 'volunteer', name: 'name',
                                                               lastname: 'lastname', birth_date: '1/1/2000',
                                                               address: '1st Street', document_number: '1.234.567-8',
                                                               document_type_id: '1' } },
                                        headers: headers
    end

    it 'returns http success' do
      expect(response).to have_http_status(:created)
    end

    it 'creates an user' do
      expect(User.count).to eq 1
    end
  end
end
