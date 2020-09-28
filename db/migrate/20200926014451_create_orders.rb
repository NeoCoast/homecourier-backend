class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.belongs_to :helpee
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
