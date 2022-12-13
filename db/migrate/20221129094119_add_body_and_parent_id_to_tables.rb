class AddBodyAndParentIdToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :related_contents, :parent_id, :integer
    add_column :objectives, :parent_id, :integer
    add_column :related_contents, :body, :string
    add_column :objectives, :body, :string
  end
end
