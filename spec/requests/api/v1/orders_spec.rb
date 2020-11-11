# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  let!(:categories) { create_list(:category, 3) }
  let!(:headers) { { 'ACCEPT' => 'application/json' } }
  let!(:volunteer) do
    create(
      :user,
      type: 'Volunteer',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end
  let!(:volunteer2) do
    create(
      :user,
      type: 'Volunteer',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end
  let!(:helpee) do
    create(
      :user,
      type: 'Helpee',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end
  let!(:helpee2) do
    create(
      :user,
      type: 'Helpee',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end
  let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
  let!(:order2) { create(:order, helpee_id: helpee.id, categories: categories) }
  let!(:order3) { create(:order, helpee_id: helpee2.id, categories: categories) }
  let!(:order4) { create(:order, helpee_id: helpee2.id, categories: categories) }
  let!(:order_delete) { create(:order, helpee_id: helpee.id, categories: categories) }
  let!(:order_created) { create(:order, helpee_id: helpee.id, categories: categories, status: :created) }
  let!(:order_accepted) { create(:order, helpee_id: helpee.id, categories: categories, status: :accepted) }
  let!(:order_in_process) { create(:order, helpee_id: helpee.id, categories: categories, status: :in_process) }
  let!(:order_finished) { create(:order, helpee_id: helpee.id, categories: categories, status: :finished) }
  let!(:order_cancelled) { create(:order, helpee_id: helpee.id, categories: categories, status: :cancelled) }

  describe 'GET /api/v1/orders' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_orders_path,
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all orders' do
      body = JSON.parse(response.body)
      expect(body.size).to eq(10)
    end
  end

  describe 'GET /api/v1/orders/:id' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_orders_path + "/#{order.id}",
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the requested order' do
      body = JSON.parse(response.body)
      expect(body['id']).to eq(order.id)
      expect(body['title']).to eq(order.title)
      expect(body['helpee']['id']).to eq(helpee.id)
      expect(body['description']).to eq(order.description)
      expect(body['categories'][0]['description']).to eq(categories[0].description)
      expect(body['categories'][1]['description']).to eq(categories[1].description)
      expect(body['categories'][2]['description']).to eq(categories[2].description)
    end
  end

  describe 'DELETE /api/v1/orders/:id' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      delete api_v1_orders_path + "/#{order_delete.id}",
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns ActiveRecord::RecordNotFound' do
      expect do
        get api_v1_orders_path + "/#{order_delete.id}",
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET /api/v1/orders/show/all' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all orders with the status accepted' do
      get api_v1_orders_path + '/show/all',
          params: { status: 'accepted' },
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      orders = JSON.parse(response.body)
      orders.each do |order_aux|
        expect(order_aux['id']).to eq(order_accepted.id)
        expect(order_aux['title']).to eq(order_accepted.title)
        expect(order_aux['helpee']['id']).to eq(helpee.id)
        expect(order_aux['description']).to eq(order_accepted.description)
        expect(order_aux['categories'][0]['description']).to eq(categories[0].description)
        expect(order_aux['categories'][1]['description']).to eq(categories[1].description)
        expect(order_aux['categories'][2]['description']).to eq(categories[2].description)
      end
    end
  end

  describe 'GET /api/v1/orders/show/helpee' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_orders_path + '/show/helpee',
          params: { helpee_id: helpee.id },
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all orders associated to the helpee' do
      body = JSON.parse(response.body)
      expect(body.size).to eq(8)
    end
  end

  describe 'GET /api/v1/orders/show/volunteer' do
    describe 'success' do
      before(:each) do
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path + '/take',
             params: { order_id: order.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_orders_path + '/show/volunteer',
            params: { volunteer_id: volunteer.id },
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'the answer has correct volunteer' do
        json = JSON.parse(response.body)
        expect(json).not_to match_array([])
      end
    end

    describe 'empty' do
      before(:each) do
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_orders_path + '/show/volunteer',
            params: { volunteer_id: volunteer.id },
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns no orders for the volunteer' do
        json = JSON.parse(response.body)
        expect(json).to match_array([])
      end
    end
  end

  describe 'GET /api/v1/orders/accept' do
    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer.email, password: volunteer.password
      } }, headers: headers
      @token = response.headers['Authorization']
      post api_v1_orders_path + '/take',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      post api_v1_orders_path + '/accept',
           params: { order_id: order.id, volunteer_id: volunteer.id },
           headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all orders associated to the helpee' do
      get api_v1_orders_path + "/#{order.id}",
          headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      json = JSON.parse(response.body)
      expect(json['status']).to eq('accepted')
    end
  end

  describe 'GET /api/v1/orders/show/volunteers' do
    describe 'success' do
      before(:each) do
        # Rating1
        # Login volunteer
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token_volunteer = response.headers['Authorization']
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order3.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }

        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee2.email, password: helpee2.password
        } }, headers: headers
        @token_helpee = response.headers['Authorization']
        # Accept
        post api_v1_orders_path + '/accept',
             params: { order_id: order3.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }

        # Login volunteer
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token_volunteer = response.headers['Authorization']
        # In process
        post api_v1_orders_path + '/status',
             params: { order_id: order3.id, status: 'in_process' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }

        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee2.email, password: helpee2.password
        } }, headers: headers
        @token_helpee = response.headers['Authorization']
        # Finished
        post api_v1_orders_path + '/status',
             params: { order_id: order3.id, status: 'finished' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Rating
        post api_v1_helpees_path + '/rating',
             params: { order_id: order3.id, score: '2', comment: Faker::Lorem.sentence },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # end Rating 1

        # Rating2
        # Login volunteer2
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer2.email, password: volunteer2.password
        } }, headers: headers
        @token_volunteer2 = response.headers['Authorization']
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order4.id, volunteer_id: volunteer2.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }

        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee2.email, password: helpee2.password
        } }, headers: headers
        @token_helpee = response.headers['Authorization']
        # Accept
        post api_v1_orders_path + '/accept',
             params: { order_id: order4.id, volunteer_id: volunteer2.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }

        # Login volunteer2
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer2.email, password: volunteer2.password
        } }, headers: headers
        @token_volunteer2 = response.headers['Authorization']
        # In process
        post api_v1_orders_path + '/status',
             params: { order_id: order4.id, status: 'in_process' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }

        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee2.email, password: helpee2.password
        } }, headers: headers
        @token_helpee = response.headers['Authorization']
        # Finished
        post api_v1_orders_path + '/status',
             params: { order_id: order4.id, status: 'finished' },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Rating
        post api_v1_helpees_path + '/rating',
             params: { order_id: order4.id, score: '4', comment: Faker::Lorem.sentence },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_helpee }
        # end Rating2

        # Volunteer
        # Login volunteer
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token_volunteer = response.headers['Authorization']
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order2.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer }
        # end take order by volunteer1

        # Volunteer2
        # Login volunteer2
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer2.email, password: volunteer2.password
        } }, headers: headers
        @token_volunteer2 = response.headers['Authorization']
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order2.id, volunteer_id: volunteer2.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token_volunteer2 }
        # end take order by volunteer2

        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        # Show volunteers
        get api_v1_orders_path + '/show/volunteers',
            params: { order_id: order2.id },
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'the answer has correct order of volunteers' do
        json = JSON.parse(response.body)
        expect(json[0]['id']).to eq(volunteer2.id)
        expect(json[0]['username']).to eq(volunteer2.username)
        expect(json[0]['email']).to eq(volunteer2.email)
        expect(json[0]['name']).to eq(volunteer2.name)
        expect(json[1]['id']).to eq(volunteer.id)
        expect(json[1]['username']).to eq(volunteer.username)
        expect(json[1]['email']).to eq(volunteer.email)
        expect(json[1]['name']).to eq(volunteer.name)
      end

      it 'returns all volunteers associated to the order' do
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
      end
    end

    describe 'empty' do
      before(:each) do
        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        # Show volunteers
        get api_v1_orders_path + '/show/volunteers',
            params: { order_id: order.id },
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all volunteers associated to the order' do
        json = JSON.parse(response.body)
        expect(json).to match_array([])
      end
    end

    describe 'the same volunteer cannot take the same order twice' do
      before(:each) do
        # Login volunteer
        post api_v1_users_path + '/login', params: { user: {
          email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        # Take
        post api_v1_orders_path + '/take',
             params: { order_id: order.id, volunteer_id: volunteer.id },
             headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        # Logout
        delete api_v1_users_path + '/logout',
               headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        # Login helpee
        post api_v1_users_path + '/login', params: { user: {
          email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        # Show volunteers
        get api_v1_orders_path + '/show/volunteers',
            params: { order_id: order.id },
            headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns all volunteers associated to the order' do
        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
      end
    end
  end
end
