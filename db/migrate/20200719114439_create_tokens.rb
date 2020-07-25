class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :post_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.string :content
      t.string :post_token_type

      t.timestamps
    end
  end
end
