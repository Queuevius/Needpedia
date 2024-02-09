class AddDefaultGroupToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :default_group_id, :integer
  end
end
