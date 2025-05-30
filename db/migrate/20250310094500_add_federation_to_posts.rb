class AddFederationToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :federated, :boolean, default: false
    add_column :posts, :federated_url, :string
    add_column :posts, :federated_author, :string
  end
end 