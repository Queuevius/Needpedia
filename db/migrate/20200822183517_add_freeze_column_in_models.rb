class AddFreezeColumnInModels < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :disabled, :boolean, default: false
    add_column :posts, :disabled, :boolean, default: false
    add_column :gigs, :disabled, :boolean, default: false
  end
end
