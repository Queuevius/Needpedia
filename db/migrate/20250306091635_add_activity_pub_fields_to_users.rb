class AddActivityPubFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :actor_id, :string
    add_column :users, :public_key_pem, :text
    add_column :users, :private_key_pem, :text
    add_column :users, :inbox_url, :string
    add_column :users, :outbox_url, :string
    add_column :users, :shared_inbox_url, :string
  end
end
