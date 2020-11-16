class AddOffsetlatitudeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :offsetlatitude, :float
  end
end
