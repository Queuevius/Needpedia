class AddCurrentChatThreadToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :current_chat_thread, null: true, foreign_key: { to_table: :chat_threads }
  end
end
