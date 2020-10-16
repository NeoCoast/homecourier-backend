# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

require 'rack/cors'
use Rack::Cors do

  allow do
    origins 'localhost:8080', 'test-homecourier-backend.herokuapp.com', 'demo-homecourier-backend.herokuapp.com'
    resource '*',
             headers: :any,
             expose: ['Authorization'],
             methods: %i[get post put patch delete options head]
  end
end
