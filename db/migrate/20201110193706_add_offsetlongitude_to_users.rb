class AddOffsetlongitudeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :offsetlongitude, :float
  end
end
