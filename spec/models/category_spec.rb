require 'rails_helper'

RSpec.describe Category, type: :model do
  let!(:category_params) { { description: 'Farmacias' } }

  describe 'Category creation' do
    it 'succeeds' do
      Category.create(category_params)
      expect(Category.count).to eq 1
    end
  end
end
