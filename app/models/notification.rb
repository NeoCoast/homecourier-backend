# frozen_string_literal: true

class Notification < ApplicationRecord
  after_create :send_notification

  validates :title, presence: true
  validates :body, presence: true

  enum status: { not_seen: 0, seen: 1 }
  validates :status, inclusion: { in: statuses.keys }

  belongs_to :user
  belongs_to :order

  private

  def send_notification
    ActionCable.server.broadcast "notifications_#{user.id}", id: id, title: title, body: body, status: status, createdAt: created_at, orderId: order.id
  end
end
