require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do

  describe "POST /api/v1/orders" do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }
    let!(:helpee_params) do
      { email: 'helpee@mail.com', password: '123456', username: 'helpee',
      name: 'name', lastname: 'lastname', birth_date: '1/1/2000',
      address: '1st Street', confirmed_at: '1900-01-01 01:01:01:000001' }
    end

    before do
      Helpee.create(helpee_params)

      post '/api/v1/categories', params: { description: 'Farmacias' }, headers: headers
      post '/api/v1/users/login', params: { user: {email: 'helpee@mail.com', password: '123456'}}, headers: headers
      
      @helpee_id = JSON.parse(response.body)['id']
      @token = response.headers['Authorization']
      
      post '/api/v1/orders', params: { title: 'Title test', description: 'Description test', helpee_id: @helpee_id, categories: [{id: 1}] },
       headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
                                                         
    end
    
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it 'creates an order' do
      expect(Order.count).to eq 1
    end
  end
end