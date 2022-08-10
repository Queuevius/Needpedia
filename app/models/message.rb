class Message < ApplicationRecord
  belongs_to :user
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :conversation

  scope :unread, -> { where(read_at: nil) }
  after_create :send_email, unless: -> { self.receiver.blocked_users&.pluck(:block_user_id)&.include?(user_id) }

  def send_email
    receiver = conversation.users.where.not(id: user_id)&.first
    return if receiver.daily_notifications? || !receiver.message_notifications?

    UserMailer.send_message_email(receiver: receiver, sender: user).deliver_now if receiver.message_notifications?
  end
end
