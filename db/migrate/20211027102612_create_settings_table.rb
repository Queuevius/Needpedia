class CreateSettingsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.boolean :freeze_accounts_activity, default: false
      t.boolean :freeze_posts_activity, default: false
      t.timestamps
    end
  end
end
