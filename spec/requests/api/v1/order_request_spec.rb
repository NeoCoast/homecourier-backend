require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/order/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/order/index"
      expect(response).to have_http_status(:success)
    end
  end

end
