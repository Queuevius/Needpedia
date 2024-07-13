class CreateAdminHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :target_type
      t.bigint :target_id
      t.text :message
      t.string :ip_address

      t.timestamps
    end
  end
end
