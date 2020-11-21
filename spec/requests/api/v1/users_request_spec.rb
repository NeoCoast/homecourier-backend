# frozen_string_literal: true

require 'rails_helper'

# UsersController
RSpec.describe 'Api::V1::Users', type: :request do
  let!(:volunteer_users) do
    create_list(
      :user, 10,
      type: 'Volunteer',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end
  let!(:helpee_users) do
    create_list(
      :user, 10,
      type: 'Helpee',
      confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)
    )
  end

  describe 'GET /api/v1/users' do
    let!(:headers) { { 'ACCEPT' => 'application/json' } }

    before(:each) do
      post api_v1_users_path + '/login', params: { user: {
        email: volunteer_users[0].email, password: volunteer_users[0].password
      } }, headers: headers
      @token = response.headers['Authorization']
      get api_v1_users_path, headers: { 'ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => @token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'the answer matches db' do
      before(:each) { @body = JSON.parse(response.body) }

      it 'number of records' do
        expect(@body.length).to eq(volunteer_users.length + helpee_users.length)
      end

      it 'content of records' do
        users = []
        volunteer_users.each do |volunteer_user|
          volunteer_tmp = {}
          volunteer_tmp['id'] = volunteer_user.attributes['id']
          volunteer_tmp['email'] = volunteer_user.attributes['email']
          volunteer_tmp['username'] = volunteer_user.attributes['username']
          volunteer_tmp['name'] = volunteer_user.attributes['name']
          volunteer_tmp['lastname'] = volunteer_user.attributes['lastname']
          volunteer_tmp['birth_date'] = volunteer_user.attributes['birth_date']
          volunteer_tmp['phone_number'] = volunteer_user.attributes['phone_number']
          volunteer_tmp['address'] = volunteer_user.attributes['address']
          volunteer_tmp['avatar'] = volunteer_user.attributes['avatar'] if volunteer_user.attributes.key?('avatar')
          volunteer_tmp['latitude'] = volunteer_user.attributes['latitude']
          volunteer_tmp['longitude'] = volunteer_user.attributes['longitude']
          volunteer_tmp['orders_completed'] = 0
          volunteer_tmp['phone_number'] = volunteer_user.attributes['phone_number']
          users.push(volunteer_tmp)
        end
        helpee_users.each do |helpee_user|
          helpee_tmp = {}
          helpee_tmp['id'] = helpee_user.attributes['id']
          helpee_tmp['email'] = helpee_user.attributes['email']
          helpee_tmp['username'] = helpee_user.attributes['username']
          helpee_tmp['name'] = helpee_user.attributes['name']
          helpee_tmp['lastname'] = helpee_user.attributes['lastname']
          helpee_tmp['birth_date'] = helpee_user.attributes['birth_date']
          helpee_tmp['phone_number'] = helpee_user.attributes['phone_number']
          helpee_tmp['address'] = helpee_user.attributes['address']
          helpee_tmp['avatar'] = helpee_user.attributes['avatar'] if helpee_user.attributes.key?('avatar')
          helpee_tmp['latitude'] = helpee_user.attributes['latitude']
          helpee_tmp['longitude'] = helpee_user.attributes['longitude']
          helpee_tmp['orders_completed'] = 0
          helpee_tmp['phone_number'] = helpee_user.attributes['phone_number']
          users.push(helpee_tmp)
        end
        expect(@body).to match_array(users)
      end
    end
  end
end
