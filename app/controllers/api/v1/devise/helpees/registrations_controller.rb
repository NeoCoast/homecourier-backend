# frozen_string_literal: true

class Api::V1::Devise::Helpees::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.save
    if resource.persisted?
      render json: resource, status: :created
    else
      head :bad_request
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password username name lastname
                                                         birth_date address type avatar])
  end
end
