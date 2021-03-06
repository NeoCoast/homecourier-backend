# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  let!(:helpee) { create(:user, type: 'Helpee') }
  let!(:volunteer) { create(:user, type: 'Volunteer') }
  let!(:categories) { create_list(:category, 3) }
  let!(:order) { create(:order, helpee_id: helpee.id, categories: categories) }

  it 'order_new_postulations_email is sent' do
    expect do
      NotificationMailer.with(user: helpee, volunteer: volunteer, order: order).order_new_postulations_email.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'order_accepted_email is sent' do
    expect do
      NotificationMailer.with(user: helpee, order: order).order_accepted_email.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'order_in_process_email is sent' do
    expect do
      NotificationMailer.with(user: helpee, volunteer: volunteer, order: order).order_in_process_email.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'order_finished_email is sent' do
    expect do
      NotificationMailer.with(user: helpee, volunteer: volunteer, order: order).order_finished_email.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'order_finished_email_volunteer is sent' do
    expect do
      NotificationMailer.with(user: helpee, order: order).order_finished_email_volunteer.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'order_cancelled_email is sent' do
    expect do
      NotificationMailer.with(user: helpee, order: order).order_cancelled_email.deliver_now
    end.to change { ActionMailer::Base.deliveries.size }.by(1)
  end
end
