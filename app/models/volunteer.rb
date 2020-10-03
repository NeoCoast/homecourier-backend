class Volunteer < User
  validates :document_number, presence: true
  validates :document_type_id, presence: true
  has_one :document_type

  has_many :order_requests
  has_many :orders, :through => :order_requests
end
