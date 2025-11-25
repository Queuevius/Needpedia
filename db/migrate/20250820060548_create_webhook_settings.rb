class CreateWebhookSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :webhook_settings do |t|
      t.string :key
      t.text :value
      t.timestamps
    end

    add_index :webhook_settings, :key, unique: true
  end
end
