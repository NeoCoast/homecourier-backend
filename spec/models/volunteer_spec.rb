require 'rails_helper'

RSpec.describe Volunteer, type: :model do
  let!(:volunteer_params) do
    { email: 'test@test.com', password: '123456', username: 'test',
      name: 'name', lastname: 'lastname', birth_date: '1/1/2000', address: '1st Street',
      document_number: '1.234.567-8', document_type_id: '1' }
  end

  describe 'Volunteer creation' do
    it 'succeeds' do
      Volunteer.create(volunteer_params)
      expect(Volunteer.count).to eq 1
    end

    context 'fails' do
      before do
        Volunteer.create(volunteer_params)
      end

      it 'due to validations' do
        expect { Volunteer.create!(volunteer_params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
