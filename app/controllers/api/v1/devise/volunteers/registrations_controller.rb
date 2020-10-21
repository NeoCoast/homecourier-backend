# frozen_string_literal: true

# Controller for Volunteers registrations
class Api::V1::Devise::Volunteers::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  # POST /resource
  def create
    build_resource(sign_up_params)
    if !adult(resource.birth_date)
      render json: { error: 'User must have 18 years old.' }, status: :bad_request
    else
      resource.save
      if resource.persisted?
        render json: resource, status: :created
      else
        render json: resource.errors, status: :bad_request
      end
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password username name lastname birth_date
                                                         address type document_number document_type_id
                                                         avatar document_face_pic document_back_pic])
  end

  private

  def adult(date)
    date_of_birth = Date.strptime(date, '%d/%m/%Y')
    return true if Date.today.year - date_of_birth.year > 18
    return false if Date.today.year - date_of_birth.year < 18

    return false if Date.today.month < date_of_birth.month
    return true if Date.today.month > date_of_birth.month

    Date.today.day >= date_of_birth.day if Date.today.month == date_of_birth.month
  end
end
