class CreateBannedTerms < ActiveRecord::Migration[6.0]
  def change
    create_table :banned_terms do |t|
      t.string :term

      t.timestamps
    end
  end
end
