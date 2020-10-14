class Api::V1::VolunteersController < ApplicationController
  before_action :authenticate_user!, :volunteer?

  def index
    @volunteers = Volunteer.all
  end

  def rating
    @order_request = OrderRequest.find_by("order_id = ? AND order_request_status = ?", params[:order_id], OrderRequest.order_request_statuses[:accepted])
    if @order_request != nil then 
      @rating = VolunteerRating.new
      @rating.order_id = params[:order_id]
      @rating.qualifier_id = @order_request.volunteer.id
      @rating.qualified_id = @order_request.order.helpee.id
      @rating.score = params[:score]
      @rating.comment = params[:comment]
      @rating.save!
      head :ok
    else
      head :bad_request
    end
  end

  def rating_pending
    @volunteer_id = params[:user_id]
    @orders = OrderRequest.select("order_id").where("volunteer_id = ? AND order_request_status = ?", @volunteer_id, OrderRequest.order_request_statuses[:accepted])
    
    @orders_ids = []
    @orders.each do |order|
      @orders_ids.push order["order_id"]
    end

    @order = Order.find_by("id = ? AND status = ?", @orders_ids, Order.statuses[:finished])
    @rating = VolunteerRating.where("order_id = ? and qualifier_id = ?", @order.id, @volunteer_id).first()
  end

  private

  def volunteer?
    head :unauthorized unless current_user.type == 'Volunteer'
  end

  def volunteer_params
    params.permit(:id)
  end

end
