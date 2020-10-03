class Volunteer < User
  validates :document_number, presence: true
  validates :document_type, presence: true

  belongs_to :document_type

  has_one_attached :document_face_pic
  has_one_attached :document_back_pic
end
