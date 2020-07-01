class CreateLike< ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :likeable_id
      t.string :likeable_type

      t.timestamps
    end
  end
end
