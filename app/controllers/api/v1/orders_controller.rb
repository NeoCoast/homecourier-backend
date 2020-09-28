class Api::V1::OrdersController < ApplicationController
  include ExceptionHandler

  before_action :load_helpee, only: [:create, :index, :show]

      def create
        @category_ids = []
        params.extract!(:categories)["categories"].each do |category|
          @category_ids.push category["id"]
        end
        
        @order = @helpee.order.create! order_params
        #@order = Order.create!(order_params)        
        
        @categories = Category.where(:id => @category_ids)        
        @order.categories << @categories        
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

      private

      def order_params
        params.permit(:title, :description)
      end

      def load_helpee
        @helpee = User.find(params[:helpee_id])
      end
end
