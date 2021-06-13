class AddCuratedToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :curated, :boolean, default: false
  end
end
