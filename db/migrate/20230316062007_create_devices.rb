class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.string :registration_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
