class Api::V1::VolunteersController < ApplicationController
  before_action :authenticate_user!, :volunteer?

  def index
    @volunteers = Volunteer.all
  end

  def orders_volunteers
    @orders = Volunteer.find(params[:id]).orders
  end

  private

  def volunteer?
    head :unauthorized unless current_user.type == 'Volunteer'
  end
end
