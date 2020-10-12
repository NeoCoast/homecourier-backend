class Api::V1::HelpeesController < ApplicationController
  before_action :authenticate_user!, :helpee?

  def index
    @helpees = Helpee.all
  end

  def show
    @helpee = Helpee.find(params[:id])
  end

  private

  def helpee?
    head :unauthorized unless current_user.type == 'Helpee'
  end
end
