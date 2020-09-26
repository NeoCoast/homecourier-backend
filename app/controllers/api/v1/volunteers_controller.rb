class Api::V1::VolunteersController < ApplicationController
  before_action :authenticate_user!, :volunteer?

  def index
    @volunteers = Volunteer.all
  end

  private

  def volunteer?
    render json: {}, status: :unauthorized unless current_user.type == 'Volunteer'
  end
end
