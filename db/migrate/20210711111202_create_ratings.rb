class CreateRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :rating
      t.bigint :rateable_id
      t.string :rateable_type

      t.timestamps
    end
  end
end
