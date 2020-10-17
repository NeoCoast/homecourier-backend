class HelpeeRating < ApplicationRecord
  belongs_to :order, foreign_key: 'order_id'
  belongs_to :helpee, foreign_key: 'qualifier_id', class_name: 'Helpee'
  belongs_to :volunteer, foreign_key: 'qualified_id', class_name: 'Volunteer'

  validates :score, presence: true
  validates :comment, presence: true, if: :is_low_score?

  def is_low_score?
    score < 3
  end
end
