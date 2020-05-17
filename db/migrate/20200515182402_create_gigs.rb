class CreateGigs < ActiveRecord::Migration[6.0]
  def change
    create_table :gigs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :area_tag
      t.string :body
      t.integer :amount

      t.timestamps
    end
  end
end
