class AddGroupIdToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :group_id, :integer
  end
end
