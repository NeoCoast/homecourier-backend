require 'rails_helper'

RSpec.describe "Api::V1::Categories", type: :request do
    describe 'POST /api/v1/categories' do
        let!(:headers) { { 'ACCEPT' => 'application/json' } }
    
        before do
          post '/api/v1/categories', params: { description: 'Farmacias' }, headers: headers
        end
    
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
    
        it 'creates a category' do
          expect(Category.count).to eq 1
        end
    end
end
