require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
	
	let!(:categories) { create_list(:category, 3) }
	let!(:headers) { { 'ACCEPT' => 'application/json' } }
	let!(:volunteer) { create(:user, type: 'Volunteer', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
	let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
	let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
	let!(:order_delete) { create(:order, helpee_id: helpee.id, categories: categories) }
	let!(:order_created) { create(:order, helpee_id: helpee.id, categories: categories, status: :created) }
	let!(:order_accepted) { create(:order, helpee_id: helpee.id, categories: categories, status: :accepted) }
	let!(:order_in_process) { create(:order, helpee_id: helpee.id, categories: categories, status: :in_process) }
	let!(:order_finished) { create(:order, helpee_id: helpee.id, categories: categories, status: :finished) }
	let!(:order_cancelled) { create(:order, helpee_id: helpee.id, categories: categories, status: :cancelled) }

  describe "GET /api/v1/orders" do

		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
      get api_v1_orders_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

		it 'returns http success' do
			expect(response).to have_http_status(:ok)
    end

		it 'returns all orders' do
			body = JSON.parse(response.body)
			expect(body.size).to eq(7)
		end
	end
	
	describe "GET /api/v1/orders/:id" do

		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
      get api_v1_orders_path + "/#{order.id}", headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
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
	
	describe "DELETE /api/v1/orders/:id" do
		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
      delete api_v1_orders_path + "/#{order_delete.id}", headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
		end
		
		it 'returns http success' do
			expect(response).to have_http_status(:ok)
		end
		
		it 'returns ActiveRecord::RecordNotFound' do
			expect{
				get api_v1_orders_path + "/#{order_delete.id}",
					headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
			}.to raise_error(ActiveRecord::RecordNotFound)
		end
	end

	describe "GET /api/v1/orders/show/all" do
		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
		end

		it 'returns http success' do
			expect(response).to have_http_status(:ok)
		end

		it 'returns all orders with the status accepted' do
			get api_v1_orders_path + '/show/all', params: { status: "accepted" },  headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
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

	describe "GET /api/v1/orders/show/helpee" do
		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: helpee.email, password: helpee.password
      } }, headers: headers
			@token = response.headers['Authorization']
			get api_v1_orders_path + "/show/helpee", params:{ helpee_id: helpee.id }, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
		end

		it 'returns http success' do
			expect(response).to have_http_status(:ok)
		end

		it 'returns all orders associated to the helpee' do
			body = JSON.parse(response.body)
			expect(body.size).to eq(7)
		end
	end

	describe "GET /api/v1/orders/show/volunteers" do
		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
		end

		it 'returns http success' do
			get api_v1_orders_path + "/show/volunteers", params:{ volunteer_id: volunteer.id, order_id: order.id }, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
			expect(response).to have_http_status(:ok)
		end
	end

	describe "GET /api/v1/orders/accept" do
		before(:each) do
      post api_v1_users_path + "/login", params: { user: {
          email: volunteer.email, password: volunteer.password
      } }, headers: headers
			@token = response.headers['Authorization']
			post api_v1_orders_path + "/take", params: { order_id: order.id, volunteer_id: volunteer.id },
																				 headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
			post api_v1_orders_path + "/accept", params: { order_id: order.id, volunteer_id: volunteer.id },
																						headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
		end

		it 'returns http success' do
			expect(response).to have_http_status(:ok)
		end

		it 'returns all orders associated to the helpee' do
			get api_v1_orders_path + "/#{order.id}", headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
			json = JSON.parse(response.body)
			expect(json["status"]).to eq("accepted") 
		end

	end

end
