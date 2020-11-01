# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

require 'rack/cors'
use Rack::Cors do

  allow do
    if ENV['ORIGIN'].present?
      origins ENV.fetch("ORIGIN")
    else
      origins 'http://localhost:8080'
    end
    
    resource '*',
             headers: :any,
             expose: ['Authorization'],
             methods: %i[get post put patch delete options head]
  end
end
