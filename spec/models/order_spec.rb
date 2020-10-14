require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:category) { create(:category) }
  let!(:helpee) { create(:user, type: 'Helpee') }
  let!(:order_params) { build(:order) }

  subject do
    described_class.new(
        title: order_params.title,
        description: order_params.description,
        status: order_params.status,
        helpee_id: helpee.id
    )
  end

  describe 'Order creation' do
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
      context 'title is empty' do
        before(:each) { subject.title = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'description is empty' do
        before(:each) { subject.description = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'helpee is empty' do
        before(:each) { subject.helpee_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end

  describe 'Order transitions' do
    context 'succeeds' do

      it 'has default state' do
        expect(subject.status).to eq "created"
      end

      it 'valid transitions' do
        subject.accept!
        subject.start!
        subject.finish!
        expect(subject.status).to eq "finished"
      end
      
    end

    context 'fails' do

      context 'created -> finished' do
        it { expect { subject.finish! }.to raise_error(AASM::InvalidTransition) }
      end

      context 'accepted -> finished' do
        before() { subject.accept!}
        it { expect { subject.finish! }.to raise_error(AASM::InvalidTransition) }
      end
      
    end

  end
end
