class AddGroupIdToPostTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :post_tokens, :group_id, :integer
  end
end
