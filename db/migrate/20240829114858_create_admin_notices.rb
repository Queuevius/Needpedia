class CreateAdminNotices < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_notices do |t|
      t.string :key
      t.text :content
      t.string :color

      t.timestamps
    end
  end
end
