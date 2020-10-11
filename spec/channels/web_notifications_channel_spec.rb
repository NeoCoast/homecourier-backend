require 'rails_helper'

RSpec.describe WebNotificationsChannel, type: :channel do
  let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  before do
    stub_connection current_user: helpee
  end

  it 'subscribes without streams' do
    subscribe
    expect(subscription).to be_confirmed
  end
end
