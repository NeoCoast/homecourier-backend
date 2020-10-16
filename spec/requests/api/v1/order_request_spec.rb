require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do

  let!(:headers) { { 'ACCEPT' => 'application/json' } }

  describe "GET /api/v1/orders" do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:orders) { create_list(:order, 10, helpee_id: helpee.id, categories: categories) }

    before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_orders_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do

      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq orders.length
      end

      it 'content of records' do
        orders_body = []
        @body.each do |order_body|
          order_response_body = order_body.slice("id", "title", "description")
          orders_body << order_response_body
        end
        orders_array = []
        orders.each do |order|
          order_response = order.attributes.slice("id", "title", "description")
          orders_array << order_response
        end
        expect(orders_body).to match_array(orders_array)
      end
    end
  end

  describe 'POST /api/v1/orders' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:category) { create(:category) }
    let!(:categories) { create_list(:category, 3) }
    let!(:order) { build(:order, categories: categories) }

    subject do
      {
          title: order.title,
          description: order.description,
          status: order.status,
          helpee_id: helpee.id,
          categories: [ { "id": category.id } ]
      }
    end

    context 'succeeds' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path, params: subject, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'creates a order' do
        expect(Order.count).to eq 1
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
      end

      it 'title is empty' do
        subject['title'] = nil
        expect { post api_v1_orders_path, params: subject, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        } }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'description is empty' do
        subject['description'] = nil
        expect { post api_v1_orders_path, params: subject, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        } }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'helpee is empty' do
        subject['helpee_id'] = nil
        expect { post api_v1_orders_path, params: subject, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET /api/v1/orders/:id' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }

    context 'succeeds' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_orders_path + "/" + order.id.to_s, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'order is obtained' do
        body = JSON.parse(response.body)
        expect(Order.exists?(body['id'])).to eq true
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        get api_v1_orders_path "/" + Faker::Number.number(digits: 55).to_s, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        }
      end

      it 'returns http unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'order is not obtained' do
        expect(response.body).to eq "You need to sign in or sign up before continuing."
      end
    end
  end

  describe 'DELETE /api/v1/orders/:id' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }

    context 'succeeds' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        delete api_v1_orders_path + "/" + order.id.to_s, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'order is deleted' do
        expect(Order.exists?(order.id)).to eq false
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
      end

      it { expect {
        delete api_v1_orders_path + "/" + Faker::Number.number(digits: 10).to_s, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        }
      }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  describe "GET /api/v1/show/all" do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:orders) { create_list(:order, 10, helpee_id: helpee.id, status: 0, categories: categories) }

    before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_orders_path + "/show/all?status=created", headers: {
          'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
      }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do

      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq orders.length
      end

      it 'content of records' do
        orders_body = []
        @body.each do |order_body|
          order_response_body = order_body.slice("id", "title", "description", "status")
          orders_body << order_response_body
        end
        orders_array = []
        orders.each do |order|
          order_response = order.attributes.slice("id", "title", "description", "status")
          orders_array << order_response
        end
        expect(orders_body).to match_array(orders_array)
      end
    end
  end

  describe 'POST /api/v1/orders/take' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
    let!(:volunteer) { create(:user, type: 'Volunteer') }

    subject do
      {
          order_id: order.id,
          volunteer_id: volunteer.id
      }
    end

    context 'succeeds' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path + "/take", params: subject, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'creates a order_request' do
        expect(Order.find(order.id).volunteers.count).to eq 1
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
      end

      it 'order is empty' do
        subject['order_id'] = nil
        expect { post api_v1_orders_path, params: subject, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        } }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'volunteer is empty' do
        subject['volunteer_id'] = nil
        expect { post api_v1_orders_path, params: subject, headers: {
            'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token
        } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST /api/v1/orders/status' do
    let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
    let!(:categories) { create_list(:category, 3) }
    let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
    let!(:volunteer) { create(:user, type: 'Volunteer') }

    subject do
      {
          order_id: order.id,
          status: "accepted"
      }
    end

    context 'succeeds' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: helpee.email, password: helpee.password
        } }, headers: headers
        @token = response.headers['Authorization']
        post api_v1_orders_path + "/take", params: { order_id: order.id, volunteer_id: volunteer.id }, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
        post api_v1_orders_path + "/status", params: subject, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'update status' do
        expect(Order.find(order.id).status).to eq "accepted"
      end
    end

    context 'fails' do
      before(:each) do
        post api_v1_users_path + "/login", params: { user: {
            email: volunteer.email, password: volunteer.password
        } }, headers: headers
        @token = response.headers['Authorization']
        subject['status'] = "finish"
        post api_v1_orders_path + "/status", params: subject, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
      end

      it 'invalid transition' do
        expect(Order.find(order.id).status).to eq "created"
      end
    end
  end
end