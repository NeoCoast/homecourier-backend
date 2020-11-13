class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  before_validation :geocode, if: :address_changed?

  after_validation :set_offset_coordinates, if: :address_changed?

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
  validates_with AgeValidator

  geocoded_by :address

  has_one_attached :avatar
  has_many :notifications

  def set_offset_coordinates
    max_radius = 300
    coordinates = random_location(longitude, latitude, max_radius)
    self.offsetlatitude = coordinates[1]
    self.offsetlongitude = coordinates[0]
  end

  def random_point_in_disk(max_radius)
    r = max_radius * rand**0.5
    theta = rand * 2 * Math::PI
    [r * Math.cos(theta), r * Math.sin(theta)]
  end

  def random_location(lon, lat, max_radius)
    dx, dy = random_point_in_disk(max_radius)
    earth_radius = 6371 # km
    one_degree = earth_radius * 2 * Math::PI / 360 * 1000 # 1 degree latitude in meters
    random_lat = lat + dy / one_degree
    random_lon = lon + dx / (one_degree * Math.cos(lat * Math::PI / 180))
    [random_lon, random_lat]
  end
end
