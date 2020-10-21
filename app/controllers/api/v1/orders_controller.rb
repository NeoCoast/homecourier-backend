# frozen_string_literal: true

# OrdersController
class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_helpee, only: [:create]
  before_action :load_params, only: [:update_status]

  def create
    @category_ids = []
    params.extract!(:categories)['categories'].each do |category|
      @category_ids.push category['id']
    end
    @order = Order.new
    @order.helpee_id = @helpee.id
    @order.title = params[:title]
    @order.description = params[:description]
    @order.categories << Category.where(id: @category_ids)
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
    @orders = Order.where(status: Order.statuses[params[:status]]).order('created_at DESC')
  end

  def orders_helpee
    @orders = Order.where(helpee_id: params[:helpee_id]).order('created_at DESC')
  end

  def order_volunteers
    @volunteers = Volunteer.joins(:orders).where('orders.id = ?', params[:order_id]).order('users.name ASC')
  end

  def volunteer_orders
    @volunteer = Volunteer.find(params[:volunteer_id])
    @orders = @volunteer.orders.order('created_at DESC')
  end

  def accept_volunteer
    # the order must be in the state created
    # the order_request must exist and the status must be waiting
    # delete all the other requests
    order = Order.find(params[:order_id])
    order.accept!
    order_request = OrderRequest.find_by!(order_id: params[:order_id], volunteer_id: params[:volunteer_id])
    order_request.accept!
    OrderRequest.delete(OrderRequest.where('order_id = ? AND Volunteer_id <> ?',
                                           params[:order_id], params[:volunteer_id]))
    volunteer = Volunteer.find(params[:volunteer_id])
    volunteer.notifications.create!(title: 'Aceptado', body: "El pedido #{order.title} ha sido aceptado")
    head :ok
  end

  def take_order
    order = Order.find(params[:order_id])
    volunteer = Volunteer.find(params[:volunteer_id])
    
    if order.created? and !order.volunteers.exists?(volunteer.id) then
      order.volunteers << volunteer
      order.helpee.notifications.create!(title: 'Postulacion', body: "El voluntario #{volunteer.username} se ha postulado al pedido #{order.title}")
      head :ok
    else
      head :not_acceptable
    end
  end

  def update_status
    case params[:status]
    when 'accepted'
      @order.accept!
      @volunteer.notifications.create!(title: 'Aceptado', body: "El pedido #{@title} ha sido aceptado")
    when 'in_process'
      @order.start!
      @helpee.notifications.create!(title: 'En proceso', body: "Su pedido #{@title} ya se encuentra en camino")
    when 'finished'
      @order.finish!
      @volunteer.notifications.create!(title: 'Finalizado', body: "El pedido #{@title} ha sido finalizado")
    when 'cancelled'
      @order.cancel!
      @helpee.notifications.create!(title: 'Cancelado', body: "El pedido #{@title} ha sido cancelado")
      @volunteer.notifications.create!(title: 'Cancelado', body: "El pedido #{@title} ha sido cancelado")
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
    @volunteer = Volunteer.find(OrderRequest.find_by!(order_id: params[:order_id]).volunteer.id)
    @title = @order.title
  end
end
