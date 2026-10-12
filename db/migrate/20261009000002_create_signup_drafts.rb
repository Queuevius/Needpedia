class CreateSignupDrafts < ActiveRecord::Migration[6.0]
  def change
    create_table :signup_drafts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at

      t.timestamps
    end
    add_index :signup_drafts, :token, unique: true
  end
end
