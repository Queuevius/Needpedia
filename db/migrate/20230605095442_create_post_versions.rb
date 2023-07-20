class CreatePostVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :post_versions do |t|
      t.references :post, foreign_key: true
      t.text :content
      t.datetime :modification_date
      t.references :user, foreign_key: true
      t.references :restored_by, foreign_key: { to_table: :users }
      t.boolean :active, default: false
      t.timestamps
    end
  end
end
