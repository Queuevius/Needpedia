class AddFieldsToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :group_id, :integer
    add_column :groups, :group_type, :string
  end
end
