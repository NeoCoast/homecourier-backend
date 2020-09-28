class AddStatusToOrders < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE status AS ENUM ('created', 'accepted', 'inProcess', 'finished', 'cancelled');
    SQL
    add_column :orders, :status, :status
  end

  def down
    remove_column :orders, :status
    execute <<-SQL
      DROP TYPE status;
    SQL
  end

end
