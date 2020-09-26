class Api::V1::HelpeesController < ApplicationController
  before_action :authenticate_user!

  def index
    @volunteers = Helpee.all
  end
end
