# frozen_string_literal: true

class PendingRatingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pending_rating_#{current_user.id}"
  end
end
