class AddRestoreAtToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :restore_at, :datetime
  end
end
