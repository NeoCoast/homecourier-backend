class Api::V1::UsersController < ApplicationController
  PAGE_SIZE = 50

  before_action :authenticate_user!
  before_action :index_settings, only: %i[ratings]

  def index
    @users = User.all
  end

  def profile
    @profile = User.find_by(username: params[:username])
    head :not_found if @profile.nil?
  end

  def ratings
    ratings1 = HelpeeRating.where(qualified_id: @user_id)
                           .order(created_at: :desc)
                           .limit(@page_size)
                           .offset(@offset)

    ratings2 = VolunteerRating.where(qualified_id: @user_id)
                              .order(created_at: :desc)
                              .limit(@page_size)
                              .offset(@offset)

    @ratings = ratings1 + ratings2
  end

  private

  def index_settings
    @user_id = params[:id]
    @page_size = PAGE_SIZE
    @page = params[:page].to_i || 0
    @offset = @page * @page_size
  end
end
