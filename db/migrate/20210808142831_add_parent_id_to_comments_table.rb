class AddParentIdToCommentsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :parent_id, :integer
    add_column :comments, :status, :integer, default: 0
    add_column :comments, :inappropriate,:boolean, default: false
  end
end
