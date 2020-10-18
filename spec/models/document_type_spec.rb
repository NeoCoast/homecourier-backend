# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentType, type: :model do
  let!(:document_type_params) { attributes_for(:document_type) }

  subject do
    described_class.new(document_type_params)
  end

  describe 'DocumentType creation' do
    context 'succeeds' do
      it { is_expected.to be_valid }

      context 'after save' do
        before(:each) { subject.save }

        it { is_expected.to be_persisted }
        it { expect(described_class.count).to eq 1 }

        it 'has a id' do
          expect(subject.id).to be_present
        end
        it 'has a creation date' do
          expect(subject.created_at).to be_present
        end
      end
    end

    context 'fails' do
      it 'due to validations' do
        subject.description = nil
        is_expected.to_not be_valid
      end

      it 'when creating a record in db' do
        subject.description = nil
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
