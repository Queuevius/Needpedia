class AddIndexToLoginAttempts < ActiveRecord::Migration[6.0]
  def change
    add_index :login_attempts, [:ip_address, :attempted_at]
  end
end
