class ChatThread < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :guest, optional: true
  has_many :chat_messages, dependent: :destroy

  validates :thread_id, presence: true
end
