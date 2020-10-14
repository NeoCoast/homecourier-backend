class AddStatusToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :status, :integer, default: 0
  end
end
