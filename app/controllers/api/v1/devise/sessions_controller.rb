class Api::V1::Devise::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    if self.resource.type == 'Volunteer'
      if self.resource.enabled?
        authenticate
      else 
        head :unauthorized
      end
    else
      authenticate
    end
  end


  private

  def authenticate
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  def respond_with(resource, _opts = {})
    render json: resource
  end

  def respond_to_on_destroy
    head :ok
  end
end
