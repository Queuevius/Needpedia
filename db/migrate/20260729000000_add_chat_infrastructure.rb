class AddChatInfrastructure < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_messages, :ip_address, :string
    add_index :chat_messages, :ip_address
    add_timestamps :chat_threads, null: true, default: nil
    add_column :chat_threads, :assistant_name, :string
    add_index :chat_threads, :assistant_name
  end
end
