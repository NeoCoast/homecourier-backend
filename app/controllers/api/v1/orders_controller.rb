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
    offset_orders
  end

  def show
    @order = Order.find(params[:id])
    return unless @order.accepted? || @order.in_process? || @order.finished?

    offset_coordinates(@order)
    @order.helpee.longitude = @coordinates[0]
    @order.helpee.latitude = @coordinates[1]
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy
    head :ok
  end

  def show_status
    @orders = Order.where(status: Order.statuses[params[:status]]).order('created_at DESC')
    offset_orders
  end

  def orders_helpee
    @orders = Order.where(helpee_id: params[:helpee_id]).order('created_at DESC')
    offset_orders
  end

  def order_volunteers
    @volunteers = Volunteer.joins(:orders).where('orders.id = ?', params[:order_id])
    @volunteers =
      @volunteers.select('users.*, avg(helpee_ratings.score) as score, count(helpee_ratings.score) as reviews')
                 .joins('LEFT JOIN helpee_ratings ON helpee_ratings.qualified_id = users.id')
                 .group('users.id')
                 .order('score DESC, reviews DESC, users.name ASC, users.lastname ASC')
  end

  def volunteer_orders
    @volunteer = Volunteer.find(params[:volunteer_id])
    @orders = @volunteer.orders.order('created_at DESC')
    offset_orders
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
    volunteer.notifications.create!(title: 'Has sido aceptado para un pedido',
                                    body: "Ya puedes iniciar el pedido #{order.title}")
    NotificationMailer.with(user: volunteer, order: order).order_accepted_email.deliver_now
    head :ok
  end

  def take_order
    order = Order.find(params[:order_id])
    volunteer = Volunteer.find(params[:volunteer_id])
    if order.created? && !order.volunteers.exists?(volunteer.id)
      order.volunteers << volunteer
      order.helpee.notifications.create!(title: 'Se han postulado a tu pedido',
                                         body: "Tu pedido #{order.title} tiene una nueva postulación")
      NotificationMailer.with(
        user: order.helpee,
        volunteer: volunteer,
        order: order
      ).order_new_postulations_email.deliver_now
      head :ok
    else
      head :not_acceptable
    end
  end

  def update_status
    case params[:status]
    when 'in_process'
      @order.start!
      @helpee.notifications.create!(title: 'Ha iniciado tu pedido',
                                    body: "Tu pedido #{@title} ya se encuentra en camino")
      NotificationMailer.with(
        user: @helpee, volunteer: @volunteer, order: @order
      ).order_in_process_email.deliver_now
    when 'finished'
      @order.finish!
      @helpee.notifications.create!(
        title: 'Pedido finalizado', body: "Has finalizado el pedido #{@title}"
      )
      NotificationMailer.with(
        user: @helpee, volunteer: @volunteer, order: @order
      ).order_finished_email.deliver_now
      @volunteer.notifications.create!(
        title: 'Pedido finalizado',
        body: "El usuario #{@helpee.username} ha recibido el pedido #{@title}"
      )
      NotificationMailer.with(user: @volunteer, order: @order).order_finished_email_volunteer.deliver_now
      ActionCable.server.broadcast(
        "pending_rating_#{@volunteer.id}",
        order_id: @order.id, user_id: @order.helpee.id,
        user_name: @order.helpee.name + ' ' + @order.helpee.lastname
      )
    when 'cancelled'
      status = @order.status
      @order.cancel!
      @helpee.notifications.create!(
        title: 'Pedido cancelado', body: "El pedido #{@title} ha sido cancelado"
      )
      NotificationMailer.with(user: @helpee, order: @order).order_cancelled_email.deliver_now
      if status != 'created'
        @volunteer.notifications.create!(
          title: 'Pedido cancelado', body: "El pedido #{@title} ha sido cancelado"
        )
        NotificationMailer.with(user: @volunteer, order: @order).order_cancelled_email.deliver_now
      end
    end
    return unless @order.accepted? || @order.in_process? || @order.finished?

    offset_coordinates(@order)
    @order.helpee.longitude = @coordinates[0]
    @order.helpee.latitude = @coordinates[1]
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
    if @order.status != 'created'
      @volunteer = Volunteer.find(OrderRequest.find_by!(order_id: params[:order_id]).volunteer.id)
    end
    @title = @order.title
  end

  def random_point_in_disk(max_radius)
    r = max_radius * rand**0.5
    theta = rand * 2 * Math::PI
    [r * Math.cos(theta), r * Math.sin(theta)]
  end

  def random_location(lon, lat, max_radius)
    dx, dy = random_point_in_disk(max_radius)
    earth_radius = 6371 # km
    one_degree = earth_radius * 2 * Math::PI / 360 * 1000 # 1 degree latitude in meters
    random_lat = lat + dy / one_degree
    random_lon = lon + dx / (one_degree * Math.cos(lat * Math::PI / 180))
    [random_lon, random_lat]
  end

  def offset_coordinates(order)
    helpee = Helpee.find(order.helpee.id)
    lat = helpee.latitude.nil? ? 1 : helpee.latitude
    lon = helpee.longitude.nil? ? 1 : helpee.longitude
    max_radius = 300
    @coordinates = random_location(lon, lat, max_radius)
  end

  def offset_orders
    @orders.each do |order|
      next if order.accepted? || order.in_process? || order.finished?

      offset_coordinates(order)
      order.helpee.longitude = @coordinates[0]
      order.helpee.latitude = @coordinates[1]
    end
  end
end
