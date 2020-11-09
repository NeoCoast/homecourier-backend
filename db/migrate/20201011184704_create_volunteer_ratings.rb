class CreateVolunteerRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :volunteer_ratings do |t|
      t.integer :order_id
      t.integer :qualifier_id
      t.integer :qualified_id
      t.integer :score
      t.string :comment

      t.timestamps
    end
  end
end
