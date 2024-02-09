class RemoveGroupIdFromNotification < ActiveRecord::Migration[6.0]
  def change
    remove_column :notifications, :group_id, :integer
  end
end
