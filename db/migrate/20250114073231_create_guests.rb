class CreateGuests < ActiveRecord::Migration[6.0]
  def change
    create_table :guests do |t|
      t.string :ip
      t.string :uuid

      t.timestamps
    end
  end
end
