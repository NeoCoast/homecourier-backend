# frozen_string_literal: true

# Controller for registrations
class Api::V1::Devise::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.save
    if resource.persisted?
      render json: resource, status: :created
    else
      render json: resource.errors, status: :bad_request
    end
  end
end
