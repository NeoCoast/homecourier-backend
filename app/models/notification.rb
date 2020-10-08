class Notification < ApplicationRecord
  after_create :send_notification

  validates :title, presence: true
  validates :body, presence: true

  belongs_to :user

  private

  def send_notification
    ActionCable.server.broadcast "notifications_#{user.id}", title: title, body: body
  end
end
