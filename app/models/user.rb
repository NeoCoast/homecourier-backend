class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  before_validation :geocode, if: :address_changed?

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :lastname, presence: true
  validates :birth_date, presence: true
  validates :address, presence: true
  validates :type, presence: true

  validates_with LatitudeValidator
  validates_with LongitudeValidator

  geocoded_by :address

  has_one_attached :avatar
  has_many :notifications
end
