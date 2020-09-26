class Order < ApplicationRecord
    has_many :categories, through: :order_categories

    validates :title, presence: true, length: {minimum: 5}
    validates :description, presence:true, length: {minimum: 5}
    enum status: { created: "created", accepted: "accepted", in_process: "inProcess", finished: "finished", canceled: "canceled" }

end
