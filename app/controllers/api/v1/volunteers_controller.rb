class Api::V1::VolunteersController < ApplicationController
  before_action :authenticate_user!, :volunteer?

  def index
    @volunteers = Volunteer.all
  end

  def show
    @volunteer = Volunteer.find(params[:id])
  end

  def orders_volunteers
    @orders = Volunteer.find(params[:id]).orders
  end

  def rating
    order_request = OrderRequest.find_by("order_id = ? AND order_request_status = ?", params[:order_id], OrderRequest.order_request_statuses[:accepted])
    if order_request != nil then 
      rating = VolunteerRating.new
      rating.order_id = params[:order_id]
      rating.qualifier_id = order_request.volunteer.id
      rating.qualified_id = order_request.order.helpee.id
      rating.score = params[:score]
      rating.comment = params[:comment]
      rating.save!

      order_request.order.updated_at = Time.now
      order_request.order.save
      head :ok
    else
      head :bad_request
    end
  end

  def rating_pending
    volunteer_id = params[:volunteer_id]
    @order = Order.joins(:order_requests).select("*").where('orders.status' => Order.statuses[:finished], 'order_requests.volunteer_id' => volunteer_id, 'order_requests.order_request_status' => OrderRequest.order_request_statuses[:accepted]).order("orders.updated_at").first
    @rating = VolunteerRating.where("order_id = ? and qualifier_id = ?", @order.id, volunteer_id).first
  end

  private

  def volunteer?
    head :unauthorized unless current_user.type == 'Volunteer'
  end

  def volunteer_params
    params.permit(:id)
  end
end
