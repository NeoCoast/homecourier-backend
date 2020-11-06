# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderRequest, type: :model do
  let!(:helpee) { create(:user, type: 'Helpee') }
  let!(:categories) { create_list(:category, 3) }
  let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }
  let!(:volunteer) { create(:user, type: 'Volunteer') }

  subject do
    described_class.new(
      order_id: order.id,
      volunteer_id: volunteer.id,
      order_request_status: 0
    )
  end

  describe 'Order request creation' do
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
      context 'order is empty' do
        before(:each) { subject.order_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'volunteer is empty' do
        before(:each) { subject.volunteer_id = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end

  describe 'Order_request transitions' do
    context 'succeeds' do
      it 'has default state' do
        expect(subject.order_request_status).to eq 'waiting'
      end

      it 'valid transitions' do
        subject.accept!
        expect(subject.order_request_status).to eq 'accepted'
      end
    end

    context 'fails' do
      context 'rejected -> accepted' do
        before { subject.reject! }
        it { expect { subject.accept! }.to raise_error(AASM::InvalidTransition) }
      end

      context 'accepted -> rejected' do
        before { subject.accept! }
        it { expect { subject.reject! }.to raise_error(AASM::InvalidTransition) }
      end
    end
  end
end
