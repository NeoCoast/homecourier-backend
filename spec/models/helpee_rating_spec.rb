require 'rails_helper'

RSpec.describe HelpeeRating, type: :model do
  # let!(:helpee_rating_params) { attributes_for(:helpee_rating) }
  let!(:helpee) { create(:user, type: 'Helpee') }
  let!(:order) { create(:order, helpee_id: helpee.id) }
  let!(:volunteer) { create(:user, type: 'Volunteer') }

  subject do
    described_class.new(
        score: 5,
        comment: "Excelente",
        order_id: order.id,  
        qualifier_id: helpee.id,
        qualified_id: volunteer.id
    )
  end

  describe 'Helpee Rating creation' do
    context 'succeeds' do
      it { is_expected.to be_valid }

      context 'after save' do
        before(:each) { subject.save }

        it { is_expected.to be_persisted }
        it { expect(described_class.count).to eq 1 }
        
        it 'has a creation date' do
          expect(subject.created_at).to be_present
        end
      end
    end

    context 'fails' do
      # context 'low score and comment empty' do
      #   before(:each) { subject.score = 2, subject.comment = nil }

      #   it { is_expected.to_not be_valid }
      #   it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      # end

      context 'Order is empty' do
        before(:each) { subject.order_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'Qualifier user is empty' do
        before(:each) { subject.qualifier_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'Qualified user is empty' do
        before(:each) { subject.qualified_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end