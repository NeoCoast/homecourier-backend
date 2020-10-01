require 'rails_helper'

RSpec.describe DocumentType, type: :model do
  let!(:document_type_params) do
    { description: 'doc' }
  end

  describe 'DocumentType creation' do
    it 'succeeds' do
      DocumentType.create(document_type_params)
      expect(DocumentType.count).to eq 1
    end
  end
end