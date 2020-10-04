class Order < ApplicationRecord            
    validates :title, presence: true, length: {minimum: 5}
    validates :description, presence: true, length: {minimum: 5}
    enum status: %i(created accepted in_process finished cancelled)

    has_many :order_requests, dependent: :destroy
    has_many :volunteers, :through => :order_requests
    
    belongs_to :helpee
    has_and_belongs_to_many :categories
end
