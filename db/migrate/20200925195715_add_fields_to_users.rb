class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :string, null: false, unique: true
    add_column :users, :name, :string, null: false
    add_column :users, :lastname, :string, null: false
    add_column :users, :birth_date, :string, null: false
    add_column :users, :address, :string, null: false
    add_index :users, :username, unique: true
  end
end
