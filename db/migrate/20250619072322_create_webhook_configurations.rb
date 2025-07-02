class CreateWebhookConfigurations < ActiveRecord::Migration[6.0]
  def change
    create_table :webhook_configurations do |t|
      t.string :url
      t.datetime :validate_until
      t.string :secret
      t.boolean :active
      t.text :description

      t.timestamps
    end
  end
end
