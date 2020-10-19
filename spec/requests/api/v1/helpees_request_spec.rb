# frozen_string_literal: true

require 'rails_helper'

# HelpeesController
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
          helpee_tmp = {}
          helpee_tmp['id'] = helpee.attributes['id']
          helpee_tmp['email'] = helpee.attributes['email']
          helpee_tmp['username'] = helpee.attributes['username']
          helpee_tmp['name'] = helpee.attributes['name']
          helpee_tmp['lastname'] = helpee.attributes['lastname']
          helpee_tmp['birth_date'] = helpee.attributes['birth_date']
          helpee_tmp['address'] = helpee.attributes['address']
          helpee_tmp['rating'] = helpee.attributes['volunteer_ratings']
          helpees_array.push(helpee_tmp)
        end
        expect(@body).to match_array(helpees_array)
      end
    end
  end

  describe 'GET /api/v1/helpees/:id' do
    let!(:helpee) do
      create(
        :user,
        type: 'Helpee',
        confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
      )
    end

    context 'shows helpee' do
      before do
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_helpees_path,
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
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

  describe 'POST /api/v1/helpees/rating' do
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
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      post api_v1_orders_path + '/take', params: { order_id: order.id, volunteer_id: volunteer.id },
                        headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      post api_v1_orders_path + '/accept',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }  
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']         
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'in_process'},
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token } 
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']           
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'finished'},
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      post api_v1_helpees_path + '/rating', params: { order_id: order.id , score: '4', comment: 'Hola'},
                            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']     
      get api_v1_volunteers_path + '/' + volunteer.id.to_s, headers: { 'ACCEPT' => 'application/json',
                                                                   'HTTP_AUTHORIZATION' => @token }
    end
    
    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'succeeds' do
      @body = JSON.parse(response.body)
      expect(@body['rating']).to eq '4.0'    
    end

    context 'rating avg' do
      before do
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path + '/take', params: { order_id: order2.id, volunteer_id: volunteer.id },
                          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path + '/accept',
             params: { order_id: order2.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }  
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']         
        post api_v1_orders_path + '/status',
             params: { order_id: order2.id, status: 'in_process'},
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token } 
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']           
        post api_v1_orders_path + '/status',
             params: { order_id: order2.id, status: 'finished'},
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        post api_v1_helpees_path + '/rating', params: { order_id: order2.id , score: '2', comment: 'Hola'},
                              headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']     
        get api_v1_volunteers_path + '/' + volunteer.id.to_s, headers: { 'ACCEPT' => 'application/json',
                                                                     'HTTP_AUTHORIZATION' => @token }

      end

      it 'succeeds' do
        @body = JSON.parse(response.body)
        expect(@body['rating']).to eq '3.0'    
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
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      post api_v1_orders_path + '/take', params: { order_id: order.id, volunteer_id: volunteer.id },
                        headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      post api_v1_orders_path + '/accept',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }  
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']         
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'in_process'},
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token } 
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']           
      post api_v1_orders_path + '/status',
           params: { order_id: order.id, status: 'finished'},
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }      
        post api_v1_helpees_path + '/ratingPending', params: { helpee_id: helpee.id },
        headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

  end


end
