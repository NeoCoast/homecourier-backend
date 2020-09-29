class Order < ApplicationRecord
    has_and_belongs_to_many :categories
    belongs_to :helpee, class_name: 'User'

    validates :title, presence: true, length: {minimum: 5}
    validates :description, presence:true, length: {minimum: 5}
    enum status: %i(created accepted inProcess finished cancelled)

end
