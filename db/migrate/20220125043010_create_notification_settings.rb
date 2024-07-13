class CreateNotificationSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :post_id
      t.boolean :edit_post
      t.boolean :expert_layer
      t.boolean :related_wiki_post

      t.timestamps
    end
  end
end
