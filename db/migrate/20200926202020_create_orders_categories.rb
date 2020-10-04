class CreateOrdersCategories < ActiveRecord::Migration[5.0]
    def change
      create_join_table :orders, :categories do |t|
        t.index :order_id
        t.index :category_id
      end
    end
end