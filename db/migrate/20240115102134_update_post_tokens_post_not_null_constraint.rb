class UpdatePostTokensPostNotNullConstraint < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :post_tokens, :posts
    change_column :post_tokens, :post_id, :bigint, null: true
    add_foreign_key :post_tokens, :posts, column: :post_id, on_delete: :cascade
  end
end
