class AddFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :message_notifications, :boolean, default: false
    add_column :users, :track_notifications, :boolean, default: false
    add_column :users, :daily_notifications, :boolean, default: false
    add_column :users, :daily_notification_time, :datetime
    add_column :users, :all_notifications, :boolean, default: false
  end
end
