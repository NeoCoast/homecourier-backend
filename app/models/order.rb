class Order < ApplicationRecord
    has_and_belongs_to_many :categories
    belongs_to :helpee

    validates :title, presence: true, length: {minimum: 5}
    validates :description, presence:true, length: {minimum: 5}
    enum status: { created: "created", accepted: "accepted", in_process: "inProcess", finished: "finished", cancelled: "cancelled" }

end
