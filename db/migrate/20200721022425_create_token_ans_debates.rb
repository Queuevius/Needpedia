class CreateTokenAnsDebates < ActiveRecord::Migration[6.0]
  def change
    create_table :token_ans_debates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :post_token, null: false, foreign_key: true
      t.string :content
      t.string :debate_type

      t.timestamps
    end
  end
end
