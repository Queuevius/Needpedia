class AddMasterAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :master_admin, :boolean, default: false
  end
end
