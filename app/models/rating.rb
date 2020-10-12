class Rating < ApplicationRecord
    belongs_to :order, foreign_key: 'order_id'
    belongs_to :user, foreign_key: 'qualifier_id', class_name: 'User'
    belongs_to :user, foreign_key: 'qualified_id', class_name: 'User'

    validates :score, presence: true
    validates :comment, presence: true, if: :is_low_score?

    def is_low_score?
        self.score < 3
    end
end
