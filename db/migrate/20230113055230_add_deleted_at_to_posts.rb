class AddDeletedAtToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :deleted_at, :datetime
  end
end
