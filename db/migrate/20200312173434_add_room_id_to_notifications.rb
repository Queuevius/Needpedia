class AddRoomIdToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :room_id, :integer
  end
end
