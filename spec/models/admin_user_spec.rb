# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  let(:admin_user) { build :admin_user }

  subject do
    described_class.new(
      email: admin_user.email,
      password: admin_user.password
    )
  end

  describe 'Admin user creation' do
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
      context 'email is empty' do
        before(:each) { subject.email = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'password is empty' do
        before(:each) { subject.password = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end
