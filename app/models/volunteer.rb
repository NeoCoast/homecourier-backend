class Volunteer < User
  validates :document_number, presence: true
  validates :document_type_id, presence: true
  has_one :document_type
end
