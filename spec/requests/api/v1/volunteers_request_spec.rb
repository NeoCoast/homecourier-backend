# frozen_string_literal: true

require 'rails_helper'

# VolunteersController
RSpec.describe 'Api::V1::Volunteers', type: :request do
  let!(:headers) { { 'ACCEPT' => 'application/json' } }

  Geocoder.configure(lookup: :test, ip_lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        'coordinates' => [40.7143528, -74.0059731],
        'address' => 'New York, NY, USA',
        'state' => 'New York',
        'state_code' => 'NY',
        'country' => 'United States',
        'country_code' => 'US'
      }
    ]
  )

  describe 'GET /api/v1/volunteers' do
    let!(:volunteers) do
      create_list(
        :volunteer,
        10,
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end

    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteers[0].email, password: volunteers[0].password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_volunteers_path,
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
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
          volunteer_tmp = {}
          volunteer_tmp['id'] = volunteer.attributes['id']
          volunteer_tmp['email'] = volunteer.attributes['email']
          volunteer_tmp['username'] = volunteer.attributes['username']
          volunteer_tmp['name'] = volunteer.attributes['name']
          volunteer_tmp['lastname'] = volunteer.attributes['lastname']
          volunteer_tmp['birth_date'] = volunteer.attributes['birth_date']
          volunteer_tmp['address'] = volunteer.attributes['address']
          volunteer_tmp['document_type_id'] = volunteer.attributes['document_type_id']
          volunteer_tmp['document_number'] = volunteer.attributes['document_number']
          volunteer_tmp['rating'] = volunteer.attributes['helpee_ratings']
          if volunteer.attributes.key?('document_face_pic')
            volunteer_tmp['document_face_pic'] = volunteer.attributes['document_face_pic']
          end
          if volunteer.attributes.key?('document_back_pic')
            volunteer_tmp['document_back_pic'] = volunteer.attributes['document_back_pic']
          end
          volunteers_array.push(volunteer_tmp)
        end
        expect(@body).to match_array(volunteers_array)
      end
    end
  end

  describe 'GET /api/v1/helpees/:id' do
    let!(:volunteer) do
      create(
        :user,
        type: 'Volunteer',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end

    context 'shows volunteer' do
      before do
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_volunteers_path,
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      context 'returns correct user data' do
        before do
          get api_v1_volunteers_path + '/' + volunteer.id.to_s,
              headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
          @body = JSON.parse(response.body)
        end

        it 'succeeds' do
          expect(@body['id']).to eq volunteer.id
        end
      end
    end
  end

  describe 'POST /api/v1/volunteer/rating' do
    let!(:categories) { create_list(:category, 3) }
    let!(:helpee) do
      create(
        :user,
        type: 'Helpee',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end
    let!(:volunteer) do
      create(
        :user,
        type: 'Volunteer',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
    let!(:order2) { create(:order, helpee_id: helpee.id, categories: categories) }

    before(:each) do
      # Login volunteer
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token_volunteer = response.headers['Authorization']
      # Login helpee1
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token_helpee = response.headers['Authorization']
    end

    context 'succeeds' do
      before(:each) do
        # Order1
        post api_v1_orders_path + '/take',
             params: { order_id: order.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        post api_v1_orders_path + '/accept',
             params: { order_id: order.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        post api_v1_orders_path + '/status',
             params: { order_id: order.id, status: 'in_process' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        post api_v1_orders_path + '/status',
             params: { order_id: order.id, status: 'finished' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        post api_v1_volunteers_path + '/rating',
             params: { order_id: order.id, score: '4', comment: Faker::Lorem.sentence },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        get api_v1_helpees_path + '/' + helpee.id.to_s,
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'score matches value' do
        @body = JSON.parse(response.body)
        expect(@body['rating']).to eq '4.0'
      end

      context 'rating avg' do
        before(:each) do
          # Order2
          post api_v1_orders_path + '/take',
               params: { order_id: order2.id, volunteer_id: volunteer.id },
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
          post api_v1_orders_path + '/accept',
               params: { order_id: order2.id, volunteer_id: volunteer.id },
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
          post api_v1_orders_path + '/status',
               params: { order_id: order2.id, status: 'in_process' },
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
          post api_v1_orders_path + '/status',
               params: { order_id: order2.id, status: 'finished' },
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
          post api_v1_volunteers_path + '/rating',
               params: { order_id: order2.id, score: '2', comment: Faker::Lorem.sentence },
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
          get api_v1_helpees_path + '/' + helpee.id.to_s,
              headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        end

        it 'succeeds' do
          @body = JSON.parse(response.body)
          expect(@body['rating']).to eq '3.0'
        end
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_volunteers_path + '/rating',
             params: { order_id: order.id, score: '10', comment: Faker::Lorem.sentence },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
      end

      it 'returns http bad_request' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST /api/v1/volunteer/ratingPending' do
    let!(:categories) { create_list(:category, 3) }
    let!(:helpee) do
      create(
        :user,
        type: 'Helpee',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end
    let!(:volunteer) do
      create(
        :user,
        type: 'Volunteer',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
    let!(:order2) { create(:order, helpee_id: helpee.id, categories: categories) }

    before(:each) do
      # Login volunteer
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token_volunteer = response.headers['Authorization']
      # Login helpee
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token_helpee = response.headers['Authorization']

      # Order
      post api_v1_orders_path + '/take',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
      post api_v1_orders_path + '/accept',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'in_process' },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'finished' },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
      post api_v1_volunteers_path + '/ratingPending',
           params: { volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
