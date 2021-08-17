class AddPostedToToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :posted_to_id, :integer
  end
end
