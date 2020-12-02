class CreateAdminNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_notifications do |t|
      t.text :message
      t.string :audience

      t.timestamps
    end
  end
end
