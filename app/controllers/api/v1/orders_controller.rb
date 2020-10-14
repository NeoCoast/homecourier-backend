class Api::V1::OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :load_helpee, only: [:create]
  before_action :load_params, only: [:update_status]

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

  def update_status
    case params[:status]
    when 'accepted'
      @order.accept!
    when 'in_process'
      @order.start!
      @helpee.notifications.create!(title: 'En proceso', body: "Su pedido #{@title} ya se encuentra en camino")
    when 'finished'
      @order.finish!
    when 'cancelled'
      @order.cancel!
      @helpee.notifications.create!(title: 'Cancelado', body: "El pedido #{@title} ha sido cancelado")
    end
  end

  private

  def order_params
    params.permit(:title, :description)
  end

  def load_helpee
    @helpee = Helpee.find(params[:helpee_id])
  end

  def load_params
    @order = Order.find(params[:order_id])
    @helpee = Helpee.find(Order.find(params[:order_id]).helpee.id)
    @title = @order.title
  end
end
