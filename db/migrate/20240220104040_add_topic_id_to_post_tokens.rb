class AddTopicIdToPostTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :post_tokens, :topic_id, :integer
  end
end
