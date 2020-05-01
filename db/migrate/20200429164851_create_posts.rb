class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :post_type
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.integer :area_id
      t.integer :problem_id

      t.timestamps
    end
  end
end
