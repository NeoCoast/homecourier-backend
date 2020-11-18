# frozen_string_literal: true

# OrdersController
class Api::V1::OrdersController < ApplicationController
  PAGE_SIZE = 10
  ORDER_VOLUNTEERS_PAGE_SIZE = 5

  # before_action :authenticate_user!
  before_action :load_helpee, only: [:create]
  before_action :load_params, only: [:update_status]
  before_action :index_settings, only: %i[show_status helpee_orders volunteer_orders]
  before_action :order_volunteers_index_settings, only: [:order_volunteers]

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
    order = Order.find(params[:id])
    order.destroy
    head :ok
  end

  def show_status
    asc_desc = !params[:asc_desc].nil? ? params[:asc_desc] : 'DESC'
    @orders = Order.where(status: Order.statuses[params[:status]])
                   .order("created_at #{asc_desc}")
                   .limit(@page_size)
                   .offset(@offset)
  end

  def orders_by_distance
    user = User.find(params[:user_id])
    asc_desc = !params[:asc_desc].nil? ? params[:asc_desc] : 'ASC'
    @user_coordinates = [user.latitude, user.longitude]
    form = "6371.0 * 2 * ASIN(SQRT(POWER(SIN((#{@user_coordinates[0]} - latitude) * PI() / 180 / 2), 2) +
               COS(#{@user_coordinates[0]} * PI() / 180) * COS(latitude * PI() / 180) *
               POWER(SIN((#{@user_coordinates[1]} - longitude) * PI() / 180 / 2), 2))) AS distance"
    @orders = Order.select("orders.*, users.latitude as latitude, users.longitude as longitude, #{form}")
                   .joins(:helpee)
                   .where(status: Order.statuses['created'])
                   .order("distance #{asc_desc}")
  end

  def helpee_orders
    @orders = Order.where(helpee_id: params[:helpee_id]).order('created_at DESC').limit(@page_size).offset(@offset)
  end

  def order_volunteers
    @volunteers = Volunteer.joins(:orders).where('orders.id = ?', params[:order_id])
    @volunteers =
      @volunteers.select('users.*, avg(coalesce(helpee_ratings.score,0)) as score,
                         count(coalesce(helpee_ratings.score,0)) as reviews')
                 .joins('LEFT JOIN helpee_ratings ON helpee_ratings.qualified_id = users.id')
                 .group('users.id')
                 .order('score DESC, reviews DESC, users.name ASC, users.lastname ASC')
                 .limit(@page_size)
                 .offset(@offset)
  end

  def volunteer_orders
    @volunteer = Volunteer.find(params[:volunteer_id])
    @orders = @volunteer.orders.order('created_at DESC').limit(@page_size).offset(@offset)
  end

  def accept_volunteer
    # the order must be in the state created
    # the order_request must exist and the status must be waiting
    # delete all the other requests
    order = Order.find(params[:order_id])
    order.accept!
    order_request = OrderRequest.find_by!(order_id: params[:order_id], volunteer_id: params[:volunteer_id])
    order_request.accept!
    OrderRequest.delete(OrderRequest.where('order_id = ? AND volunteer_id <> ?',
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
  end

  def orders_on_map
    north_coordinate = params[:lat_top_right]
    east_coordinate = params[:lng_top_right]
    south_coordinate = params[:lat_down_left]
    west_coordinate = params[:lng_down_left]

    @orders = Order.joins(:helpee)
                   .where(
                     'orders.status = ? and
                     users.offsetlatitude <= ? and
                     users.offsetlatitude >= ? and
                     users.offsetlongitude <= ? and
                     users.offsetlongitude >= ?', 0, north_coordinate,
                     south_coordinate, east_coordinate, west_coordinate
                   ).order('created_at DESC')
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

  def index_settings
    @page_size = PAGE_SIZE
    @page = params[:page].to_i || 0
    @offset = @page * @page_size
  end

  def order_volunteers_index_settings
    @page_size = ORDER_VOLUNTEERS_PAGE_SIZE
    @page = params[:page].to_i || 0
    @offset = @page * @page_size
  end
end
