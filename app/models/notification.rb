class Notification < ApplicationRecord

  ################################ Constants ############################
  NOTIFICATION_TYPE_ACCEPTED = 'gig_accepted'.freeze
  NOTIFICATION_TYPE_AWARDED = 'gig_awarded'.freeze
  NOTIFICATION_TYPE_FRIEND_REQUEST = 'friend_request'.freeze
  NOTIFICATION_TYPE_REQUEST_ACCEPTED = 'request_accept'.freeze
  NOTIFICATION_TYPE_REQUEST_REJECTED = 'request_rejected'.freeze
  NOTIFICATION_TYPE_POST_UPDATED = 'post_updated'.freeze

  ################################ relationships ############################
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true
  belongs_to :post, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(5) }

  def self.post(to:, from:, action:, notifiable:, post_id: nil)
    recipients = Array.wrap(to)
    notifications = []

    Notification.transaction do
      notifications = recipients.uniq.each do |recipient|
        Notification.create(
          notifiable: notifiable,
          action:     action,
          recipient:  recipient,
          actor:      from,
          post_id:    post_id
        )
      end
    end
    notifications
  end
end
