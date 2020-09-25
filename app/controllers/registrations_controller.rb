class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)
    resource.save
    if resource.persisted?
      render json: resource, status: :created
    else
      render json: {}, status: :bad_request
    end
  end
end
