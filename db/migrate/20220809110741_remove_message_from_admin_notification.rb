class RemoveMessageFromAdminNotification < ActiveRecord::Migration[6.0]
  def change
    remove_column :admin_notifications, :message
  end
end
