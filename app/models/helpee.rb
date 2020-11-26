# frozen_string_literal: true

class Helpee < User
  has_many :orders
end
