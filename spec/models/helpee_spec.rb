require 'rails_helper'

RSpec.describe Helpee, type: :model do

  let(:user) { build :user }

  subject do
    described_class.new(
        email: user.email,
        password: user.password,
        username: user.username,
        name: user.name,
        lastname: user.lastname,
        birth_date: user.birth_date,
        address: user.address
    )
  end

  describe 'Helpee creation' do
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

      context 'username is empty' do
        before(:each) { subject.username = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'name is empty' do
        before(:each) { subject.name = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'lastname is empty' do
        before(:each) { subject.lastname = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'birth date is empty' do
        before(:each) { subject.birth_date = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end

      context 'address is empty' do
        before(:each) { subject.address = nil }

        it { is_expected.to_not be_valid }
        it { expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end