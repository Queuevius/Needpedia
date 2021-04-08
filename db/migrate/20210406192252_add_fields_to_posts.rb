class AddFieldsToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :editing_disabled, :boolean, default: false
    add_column :posts, :layering_disabled, :boolean, default: false
  end
end
