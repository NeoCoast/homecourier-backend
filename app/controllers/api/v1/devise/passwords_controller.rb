# frozen_string_literal: true

class Api::V1::Devise::PasswordsController < Devise::PasswordsController
  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      head :ok
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
    if resource.errors.empty?
      head :ok
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      head :ok
    else
      set_minimum_password_length
      render json: resource.errors, status: :unprocessable_entity
    end
  end
end
