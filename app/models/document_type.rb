class DocumentType < ApplicationRecord
  validates :description, presence: true
  has_many :volunteer
end
