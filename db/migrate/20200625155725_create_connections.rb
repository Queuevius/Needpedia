class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :connection_requests do |t|
      t.belongs_to :user
      t.string :message
      t.string :status, :default => 'pending'
      t.uuid :to
      t.timestamps
    end
  end
end
