class CreateUserGigs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_gigs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :gig, null: false, foreign_key: true

      t.timestamps
    end
  end
end
