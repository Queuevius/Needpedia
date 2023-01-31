class CreateDeletions < ActiveRecord::Migration[6.0]
  def change
    create_table :deletions do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :deletable_id
      t.string :deletable_type
      t.string :reason

      t.timestamps
    end
  end
end
