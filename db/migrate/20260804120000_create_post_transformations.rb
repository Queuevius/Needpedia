class CreatePostTransformations < ActiveRecord::Migration[6.0]
  def change
    create_table :post_transformations do |t|
      t.references :user, foreign_key: true, null: true
      t.references :guest, foreign_key: true, null: true
      t.references :post, null: false, foreign_key: true
      t.string :transform_type, default: 'freeform'
      t.timestamps
    end

    add_index :post_transformations, [:user_id, :post_id], unique: true, where: "user_id IS NOT NULL"
    add_index :post_transformations, [:guest_id, :post_id], unique: true, where: "guest_id IS NOT NULL"

    create_table :post_translations do |t|
      t.references :post, null: false, foreign_key: true
      t.string :language, null: false
      t.text :content, null: false
      t.references :user, foreign_key: true, null: true
      t.timestamps
    end

    add_index :post_translations, [:post_id, :language], unique: true
  end
end
