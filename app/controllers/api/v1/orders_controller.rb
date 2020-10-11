class Api::V1::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :load_helpee, only: [:create]

  def create
    @category_ids = []
    params.extract!(:categories)["categories"].each do |category|
      @category_ids.push category["id"]
    end
    @order = Order.new
    @order.helpee_id = @helpee.id
    @order.title = params[:title]
    @order.description = params[:description]
    @order.categories << Category.where(:id => @category_ids)        
    @order.save!
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

  def orders_helpee
    @orders = Order.where(helpee_id: params[:helpee_id]).order("created_at ASC")
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
