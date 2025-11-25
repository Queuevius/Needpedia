class AddLocationToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :lat, :float
    add_column :tasks, :long, :float
    add_column :tasks, :region, :string
    add_column :tasks, :country, :string
    add_column :tasks, :postal_code, :string
  end
end


