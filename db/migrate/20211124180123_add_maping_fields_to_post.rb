class AddMapingFieldsToPost < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :lat, :decimal
    add_column :posts, :long, :decimal
    add_column :posts, :geo_maxing, :boolean, default: false
  end
end
