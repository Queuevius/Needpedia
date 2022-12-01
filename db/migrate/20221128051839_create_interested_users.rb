class CreateInterestedUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :interested_users do |t|
      t.string :content
      t.integer :parent_id
      t.belongs_to :post
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
