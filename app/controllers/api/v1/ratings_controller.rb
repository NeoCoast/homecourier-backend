class Api::V1::RatingsController < ApplicationController

    before_action :authenticate_user!
    
    def create
        if User.find(params[:qualifier_id]).type != User.find(params[:qualified_id]).type then
            @rating = Rating.create! rating_params
            head :ok     
        else
            head :unauthorized
        end
    end

    def rating_params
        params.permit(:order_id, :qualifier_id, :qualified_id, :score, :comment)
    end
end
