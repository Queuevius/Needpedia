class ConnectionsFollows < ActiveRecord::Migration[6.0]
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.integer :friend_id
      t.index [:user_id, :friend_id], unique: true
      t.timestamps
    end
  end
end
