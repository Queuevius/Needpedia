class AddAdminNotificationIdToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :admin_notification_id, :integer
  end
end
