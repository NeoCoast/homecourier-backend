require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user_params) do
    { email: 'test@test.com', password: '123456', username: 'test',
      name: 'name', lastname: 'lastname', birth_date: '1/1/2000', address: '1st Street' }
  end

  describe 'User creation' do
    it 'succeeds' do
      User.create(user_params)
      expect(User.count).to eq 1
    end

    context 'fails' do
      before do
        User.create(user_params)
      end

      it 'due to validations' do
        expect { User.create!(user_params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
