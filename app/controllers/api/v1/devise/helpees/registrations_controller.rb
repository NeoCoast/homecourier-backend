# frozen_string_literal: true

# Controller for Helpees registrations
class Api::V1::Devise::Helpees::RegistrationsController < Api::V1::Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password username name lastname
                                                         birth_date address type avatar])
  end
end
