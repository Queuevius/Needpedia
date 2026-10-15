class ChatMessage < ApplicationRecord
  belongs_to :chat_thread

  validates :role, presence: true
  # Metadata-only rows (body fully consumed by the task-draft fence strip)
  # still carry the draft in metadata — content itself may be blank.
  validates :content, presence: true, unless: -> { metadata.present? }
end






