require 'rails_helper'

RSpec.describe WebNotificationsChannel, type: :channel do
  let!(:helpee) { create(:user, type: 'Helpee', confirmed_at: Faker::Date.between(from: 30.days.ago, to: Date.today)) }

  before do
    # initialize connection with identifiers
    stub_connection user_id: helpee.id
  end

  it 'subscribes without streams' do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).not_to have_streams
  end
end
