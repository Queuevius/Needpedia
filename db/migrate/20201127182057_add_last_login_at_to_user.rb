class AddLastLoginAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_login_at, :datetime
  end
end
