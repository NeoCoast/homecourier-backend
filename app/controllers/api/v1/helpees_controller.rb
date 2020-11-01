class Api::V1::HelpeesController < ApplicationController
  before_action :authenticate_user!, :helpee?

  def index
    @helpees = Helpee.all
  end

  def rating
    order_request = OrderRequest.find_by('order_id = ? AND order_request_status = ?', params[:order_id], OrderRequest.order_request_statuses[:accepted])
    if !order_request.nil?
      rating = HelpeeRating.new
      rating.order_id = order_request.order.id
      rating.qualifier_id = order_request.order.helpee.id
      rating.qualified_id = order_request.volunteer.id
      rating.score = params[:score]
      rating.comment = params[:comment]
      rating.save!
      head :ok
    else
      head :bad_request
    end
  end

  def rating_pending
    helpee_id = params[:helpee_id]

    orders = Order.joins(:order_requests).where(
      'orders.status' => Order.statuses[:finished],
      'orders.helpee_id' => helpee_id,
      'order_requests.order_request_status' => OrderRequest.order_request_statuses[:accepted]
    ).order('orders.updated_at')
    
    @pendings = []
    orders.each do |order|
      rating = HelpeeRating.where(
        'order_id = ? and qualifier_id = ?',
        order.id,
        helpee_id
      )
      if rating.blank?
        @pendings.push order
      end
    end
  end

  def show
    @helpee = Helpee.find(params[:id])
  end

  private

  def helpee?
    head :unauthorized unless current_user.type == 'Helpee'
  end
end
