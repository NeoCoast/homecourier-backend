class DocumentType < ApplicationRecord
  validates :description, presence: true
  belongs_to :volunteers
end
