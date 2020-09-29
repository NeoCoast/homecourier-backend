class Api::V1::HelpeesController < ApplicationController
  before_action :authenticate_user!, :helpee?

  def index
    @helpees = Helpee.all
  end

  private

  def helpee?
    header :unauthorized unless current_user.type == 'Helpee'
  end
end
