class OrderRequest < ApplicationRecord
  include AASM
  enum order_request_status: %i[waiting rejected accepted]
  belongs_to :order
  belongs_to :volunteer

  # states management
  aasm column: 'order_request_status' do
    state :waiting, initial: true
    state :rejected
    state :accepted

    event :accept do
      transitions from: :waiting, to: :accepted
    end

    event :reject do
      transitions from: :waiting, to: :rejected
    end
  end
end
