class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def profile
    @profile = User.find_by(username: params[:username])
    head :not_found if @profile.nil?
  end
end
