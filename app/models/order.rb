class Order < ApplicationRecord
  include AASM
  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true, length: { minimum: 5 }
  validates :categories, presence: true
  enum status: %i[created accepted in_process finished cancelled]

  has_many :order_requests, dependent: :destroy
  has_many :volunteers, through: :order_requests

  belongs_to :helpee
  has_and_belongs_to_many :categories

  # states management
  aasm column: 'status' do
    state :created, initial: true
    state :accepted
    state :in_process
    state :finished
    state :cancelled

    event :accept do
      transitions from: :created, to: :accepted
    end

    event :start do
      transitions from: :accepted, to: :in_process
    end

    event :finish do
      transitions from: :in_process, to: :finished
    end

    event :cancel do
      transitions from: %i[created accepted in_process], to: :cancelled
    end
  end
end
