require 'rails_helper'

RSpec.describe Helpee, type: :model do
  let!(:helpee_params) do
    { email: 'test@test.com', password: '123456', username: 'test',
      name: 'name', lastname: 'lastname', birth_date: '1/1/2000', address: '1st Street' }
  end

  describe 'Helpee creation' do
    it 'succeeds' do
      Helpee.create(helpee_params)
      expect(Helpee.count).to eq 1
    end

    context 'fails' do
      before do
        Helpee.create(helpee_params)
      end

      it 'due to validations' do
        expect { Helpee.create!(helpee_params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
