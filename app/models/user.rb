class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :lastname, presence: true
  validates :birth_date, presence: true
  validates :address, presence: true
  validates :type, presence: true
end
