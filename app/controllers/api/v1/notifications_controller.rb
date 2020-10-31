class Api::V1::NotificationsController < ApplicationController
  PAGE_SIZE = 50

  before_action :authenticate_user!
  before_action :index_settings, only: %i[index index_not_seen]
  before_action :load_notification, only: [:seen]

  def index
    @notifications = Notification.where(user_id: @user_id).order(id: :desc)
                                 .limit(@page_size).offset(@offset)
  end

  def index_not_seen
    @notifications = Notification.where(user_id: @user_id, status: :not_seen)
                                 .order(id: :desc)
                                 .limit(@page_size).offset(@offset)
  end

  def seen
    @mark_as_seen.each(&:seen!)
    head :ok
  end

  private

  def index_settings
    @user_id = current_user.id
    @page_size = PAGE_SIZE
    @page = params[:page].to_i || 0
    @offset = @page * @page_size
  end

  def load_notification
    @mark_as_seen = current_user.notifications.find(params[:notifications_id])
  rescue ActiveRecord::RecordNotFound
    render json: { 'error': 'Notification ID does not belong to user' }, status: :bad_request
  end
end
