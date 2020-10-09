class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_notification, only: [:seen]

  def seen
    @notification.seen!
    head :ok
  end

  private

  def load_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { 'error': 'Notification ID does not belong to user' }, status: :bad_request
  end
end
