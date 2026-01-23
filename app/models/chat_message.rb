class ChatMessage < ApplicationRecord
  belongs_to :chat_thread

  validates :role, presence: true
  validates :content, presence: true
end






