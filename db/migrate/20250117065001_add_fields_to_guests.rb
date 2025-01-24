class AddFieldsToGuests < ActiveRecord::Migration[6.0]
  def change
    change_table :guests do |t|
      t.string :fingerprint
      t.string :last_ip
      t.string :user_agent
    end
  end
end
