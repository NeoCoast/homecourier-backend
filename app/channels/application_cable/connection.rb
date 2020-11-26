# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      find_verified_user request.params[:token]
    end

    private

    def find_verified_user(token)
      self.current_user = Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
    rescue StandardError
      reject_unauthorized_connection
    end
  end
end
