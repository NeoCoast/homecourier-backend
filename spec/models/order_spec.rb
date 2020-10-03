require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:category_params) { { description: 'Farmacias' } }
  let!(:order_params) { { title: 'Test title', description: 'Test description', helpee_id: 1 } }
  let!(:helpee_params) { { email: 'test@test.com', password: '123456', username: 'test',
      name: 'name', lastname: 'lastname', birth_date: '1/1/2000', address: '1st Street' } }

  describe 'Order creation' do
    it 'succeeds' do
      @helpee = Helpee.create(helpee_params)
      @category = Category.create(category_params)
      
      @order = @helpee.orders.create! order_params
      @order.categories << @category
      
      expect(Order.count).to eq 1
      expect(Category.count).to eq 1
    end

    context 'fails' do
      before do
        Order.create(order_params)
      end

      it 'due to validations' do
        expect { Order.create!(order_params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
