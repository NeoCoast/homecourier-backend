class Api::V1::CategoriesController < ApplicationController
    include ExceptionHandler

    #before_action :load_category, only: [:destroy]

    def create
        @category = Category.create!(category_params)
    end

    def index
        @categories = Category.all 
    end

    def show
        @category = Category.find(params[:id])
    end

    def destroy
        @category = Category.find(params[:id])
        @category.destroy
        head :no_content
    end

    private 

    def category_params
        params.permit(:description)
    end

    def load_category
        @category = Category.find.(params[:id])
    end
end
