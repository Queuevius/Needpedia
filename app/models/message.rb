class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  scope :unread, -> { where(read_at: nil) }
end
