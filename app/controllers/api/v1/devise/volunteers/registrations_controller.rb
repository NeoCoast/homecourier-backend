# frozen_string_literal: true

# Controller for Volunteers registrations
class Api::V1::Devise::Volunteers::RegistrationsController < Api::V1::Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password username name lastname birth_date
                                                         address type document_number document_type_id
                                                         avatar document_face_pic document_back_pic phone_number])
  end
end
