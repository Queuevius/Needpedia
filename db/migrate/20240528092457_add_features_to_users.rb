class AddFeaturesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :features, :jsonb, using: 'features::jsonb', default: {}, null: false
  end
end
