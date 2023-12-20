class AddGroupIdToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :group_id, :integer
  end
end
