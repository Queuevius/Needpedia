class AddGuestReferenceToChatThreads < ActiveRecord::Migration[6.0]
  def change
    add_reference :chat_threads, :guest, foreign_key: true, null: true
    change_column_null :chat_threads, :user_id, true
  end
end
