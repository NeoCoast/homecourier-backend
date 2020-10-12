require 'rails_helper'

RSpec.describe 'Api::V1::Notifications', type: :request do
  let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }
  let!(:notifications) do
    create_list(:notification, 5, user_id: helpee.id, title: Faker::Lorem.sentence,
                                  body: Faker::Lorem.paragraph)
  end

  describe 'GET /api/v1/notifications' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before do
      post api_v1_users_path + '/login', params: { user: {
        email: helpee.email, password: helpee.password
      } }, headers: headers
      @token = response.headers['Authorization']

      get api_v1_notifications_path, params: { page: 0 }, headers: { 'ACCEPT' => 'application/json',
                                                                     'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'has the same notifications' do
      @body = JSON.parse(response.body, symbolize_keys: true)
      expect(@body['notifications'].length).to eq notifications.length
    end

    context 'notification marked as seen' do
      before do
        post api_v1_notifications_path + '/seen', params: { id: notifications[0].id },
                                                  headers: { 'ACCEPT' => 'application/json',
                                                             'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'is marked as seen' do
        expect(helpee.notifications[0].status).to eq 'seen'
      end
    end

    context 'wrong notification marked as seen' do
      before do
        post api_v1_notifications_path + '/seen', params: { id: notifications[0].id - 1 },
                                                  headers: { 'ACCEPT' => 'application/json',
                                                             'HTTP_AUTHORIZATION' => @token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end