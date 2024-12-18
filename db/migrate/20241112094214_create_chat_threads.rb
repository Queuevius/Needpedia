class CreateChatThreads < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_threads do |t|
      t.string :title
      t.string :last_message
      t.string :thread_id
      t.references :user, null: false, foreign_key: true
    end
  end
end
