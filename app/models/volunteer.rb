class Volunteer < User
  validates :document_number, presence: true
end
