class CreateAiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :ai_tokens do |t|
      t.integer :tokens_count, default: 0
      t.references :user, null: true, foreign_key: true
      t.references :guest, null: true, foreign_key: true

      t.timestamps
    end
  end
end
