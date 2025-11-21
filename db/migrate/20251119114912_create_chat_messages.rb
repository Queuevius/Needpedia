class CreateChatMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_messages do |t|
      t.references :chat_thread, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :chat_messages, [:chat_thread_id, :created_at]
  end
end