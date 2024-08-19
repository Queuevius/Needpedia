class AddResetPasswordAttemptsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_password_attempts, :integer
    add_column :users, :last_reset_attempt_at, :datetime
  end
end
