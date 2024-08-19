class CreateLoginAttempts < ActiveRecord::Migration[6.0]
  def change
    create_table :login_attempts do |t|
      t.string :ip_address
      t.datetime :attempted_at
      t.boolean :success

      t.timestamps
    end
  end
end
