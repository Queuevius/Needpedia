class ChangeNotificationColumnsToString < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :message_notifications, :string, default: 'non'
    change_column :users, :track_notifications, :string, default: 'non'
  end

  def down
    change_column :users, :message_notifications, :boolean, default: false
    change_column :users, :track_notifications, :boolean, default: false
    change_column :users, :daily_notifications, :boolean, default: false
    change_column :users, :all_notifications, :boolean, default: false
  end
end
