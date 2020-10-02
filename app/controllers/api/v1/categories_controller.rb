class Api::V1::CategoriesController < ApplicationController
    before_action :load_category, only: [:show, :destroy]

    def create
        @category = Category.create!(category_params)
    end

    def index
        @categories = Category.all 
    end

    def show
        @category
    end

    def destroy
        @category.destroy
        head :ok
    end

    private 

    def category_params
        params.permit(:description)
    end

    def load_category
        @category = Category.find(params[:id])
    end
end
