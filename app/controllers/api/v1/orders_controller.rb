class Api::V1::OrdersController < ApplicationController
  include Response
  include ExceptionHandler

  #before_action :load_order, only: [:destroy]

      def create
        @order = Order.create!(order_params)
        #@order.status = "created"
        #json_response(@order, :created)
      end

      def index 
        @orders = Order.all
        #json_response(@orders)
      end

      def show
        @order = Order.find(params[:id])
        #json_response(@order)
      end

      def destroy 
        @order = Order.find(params[:id])
        @order.destroy
        head :no_content
      end

      private

      def order_params
        params.permit(:title, :description)
      end

      def load_order
        @order = Order.find(params[:id])
      end
end
