# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let!(:helpee) { create(:user, type: 'Helpee') }
  let(:notification) { build :notification }

  subject do
    described_class.new(
      user_id: helpee.id,
      title: notification.title,
      body: notification.body
    )
  end

  describe 'Notification creation' do
    context 'succeeds' do
      it { is_expected.to be_valid }

      context 'after save' do
        before(:each) { subject.save }

        it { is_expected.to be_persisted }
        it { expect(described_class.count).to eq 1 }

        it 'has a id' do
          expect(subject.id).to be_present
        end

        it 'has a user id' do
          expect(subject.user_id).to be_present
        end

        it 'has a creation date' do
          expect(subject.created_at).to be_present
        end

        it 'is marked as not seen' do
          expect(subject.status).to eq 'not_seen'
        end
      end
    end

    context 'fails' do
      context 'missing user id' do
        before(:each) { subject.user_id = nil }
        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'missing title' do
        before(:each) { subject.title = nil }
        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'missing body' do
        before(:each) { subject.body = nil }
        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end
