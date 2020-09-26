class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end

  create_table :orders_categories, id: false do |t|
    t.belongs_to :order
    t.belongs_to :category
  end

end
