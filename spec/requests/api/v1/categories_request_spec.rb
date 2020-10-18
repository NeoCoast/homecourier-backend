# frozen_string_literal: true

require 'rails_helper'

# CategoriesController
RSpec.describe 'Api::V1::Categories', type: :request do
  let!(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/categories' do
    let!(:helpee) { create(:user, type: 'Helpee') }
    let!(:categories) { create_list(:category, 10) }

    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_categories_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do
      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq categories.length
      end

      it 'content of records' do
        categories_array = []
        categories.each do |category|
          categories_array << category.attributes.slice('id', 'description')
        end
        expect(@body).to match_array(categories_array)
      end
    end
  end

  describe 'POST /api/v1/categories' do
    let!(:category) { build(:category) }

    context 'succeeds' do
      before(:each) do
        post api_v1_categories_path, params: { description: category.description }, headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'creates a category' do
        expect(Category.count).to eq 1
      end
    end

    context 'fails' do
      it {
        expect do
          post api_v1_categories_path, params: {
            description: nil
          }, headers: headers
        end .to raise_error(ActiveRecord::RecordInvalid)
      }
    end
  end

  describe 'GET /api/v1/categories/:id' do
    context 'succeeds' do
      let!(:category) { create(:category) }

      before(:each) do
        get api_v1_categories_path + '/' + category.id.to_s, headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'category is obtained' do
        body = JSON.parse(response.body)
        expect(Category.exists?(body['id'])).to eq true
      end
    end

    context 'fails' do
      before(:each) do
        get api_v1_categories_path '/' + Faker::Number.number(digits: 55).to_s, headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'category is not obtained' do
        body = JSON.parse(response.body)
        expect(body).to eq []
      end
    end
  end

  describe 'DELETE /api/v1/categories/:id' do
    context 'succeeds' do
      let!(:category) { create(:category) }

      before(:each) do
        delete api_v1_categories_path + '/' + category.id.to_s, headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'category is deleted' do
        expect(Category.exists?(category.id)).to eq false
      end
    end

    context 'fails' do
      it {
        expect do
          delete api_v1_categories_path + '/' + Faker::Number.number(digits: 10).to_s, headers: headers
        end.to raise_error(ActiveRecord::RecordNotFound)
      }
    end
  end
end
