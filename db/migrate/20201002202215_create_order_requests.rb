class CreateOrderRequests < ActiveRecord::Migration[5.2]
    def change
      create_table :order_requests do |t|
        t.belongs_to :order
        t.belongs_to :volunteer
        t.integer :order_request_status, default: 0
        
        t.timestamps
      end
    end
end