class Api::V1::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :load_helpee, only: [:create]

  def create
    @category_ids = []
    params.extract!(:categories)["categories"].each do |category|
      @category_ids.push category["id"]
    end
    
    @order = @helpee.orders.create! order_params
    @order.categories << Category.where(:id => @category_ids)        
  end

  def index 
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
  end

  def destroy 
    @order = Order.find(params[:id])
    @order.destroy
    head :ok
  end

  def show_status
    @orders = Order.where(status: Order.statuses[params[:status]]).order("created_at DESC")
  end

  def take_order
    @order = Order.find(params[:order_id])
    @order.volunteers << Volunteer.find(params[:volunteer_id])
    head :ok
  end

  private

  def order_params
    params.permit(:title, :description)
  end

  def load_helpee
    @helpee = Helpee.find(params[:helpee_id])
  end
end
