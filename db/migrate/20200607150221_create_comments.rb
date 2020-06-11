class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :commentable_id
      t.string :commentable_type
      t.string :body

      t.timestamps
    end
  end
end
