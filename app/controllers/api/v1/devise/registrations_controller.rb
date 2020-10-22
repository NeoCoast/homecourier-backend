# frozen_string_literal: true

# Controller for registrations
class Api::V1::Devise::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /resource
  def create
    build_resource(sign_up_params)
    if !resource.birth_date.nil? && !adult(resource.birth_date)
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
