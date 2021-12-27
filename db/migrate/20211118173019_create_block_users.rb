class CreateBlockUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_users do |t|
      t.references :user
      t.integer :block_user_id
      t.timestamps
    end
  end
end
