class Volunteer < User
  validates :document_number, presence: true, uniqueness: { scope: [:document_type] }
  validates :document_type, presence: true

  belongs_to :document_type

  has_one_attached :document_face_pic
  has_one_attached :document_back_pic

  has_many :helpee_ratings
  has_many :order_requests
  has_many :orders, through: :order_requests
end
