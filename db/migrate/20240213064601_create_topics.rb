class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.belongs_to :group, foreign_key: true
      t.integer :parent_id
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
