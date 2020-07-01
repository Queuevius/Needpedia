class CreateShares < ActiveRecord::Migration[6.0]
  def change
    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :shareable_id
      t.string :shareable_type

      t.timestamps
    end
  end
end
