class AddStatusToOrders < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE order_status AS ENUM ('createed', 'accepted', 'inProcess', 'finished', 'cancelled');
    SQL
    add_column :orders, :status, :order_status
  end

  def down
    remove_column :orders, :status
    execute <<-SQL
      DROP TYPE order_status;
    SQL
  end

end
