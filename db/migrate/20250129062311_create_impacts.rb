class CreateImpacts < ActiveRecord::Migration[6.0]
  def change
    create_table :impacts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :description
      t.string :badge

      t.timestamps
    end
  end
end
