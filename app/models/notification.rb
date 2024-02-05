class Notification < ApplicationRecord

  ################################ Constants ############################
  NOTIFICATION_TYPE_ACCEPTED = 'gig_accepted'.freeze
  NOTIFICATION_TYPE_AWARDED = 'gig_awarded'.freeze
  NOTIFICATION_TYPE_FRIEND_REQUEST = 'friend_request'.freeze
  NOTIFICATION_TYPE_REQUEST_ACCEPTED = 'request_accept'.freeze
  NOTIFICATION_TYPE_REQUEST_REJECTED = 'request_rejected'.freeze
  NOTIFICATION_TYPE_POST_CREATED = 'post_created'.freeze
  NOTIFICATION_TYPE_POST_UPDATED = 'post_updated'.freeze
  NOTIFICATION_TYPE_ADMIN_NOTIFICATION = 'admin_notification'.freeze
  NOTIFICATION_TYPE_POST_USER_ADDED = 'user_added'.freeze
  NOTIFICATION_TYPE_POST_CURATED_USER_ADDED = 'curated_user_added'.freeze
  NOTIFICATION_TYPE_POST_CURATED_USER_REMOVED = 'curated_user_removed'.freeze
  NOTIFICATION_TYPE_COMMENT_EDITED = 'comment_edited'.freeze
  NOTIFICATION_TYPE_COMMENT_DELETED = 'comment_deleted'.freeze
  NOTIFICATION_TYPE_COMMENT_CREATED = 'comment_created'.freeze
  NOTIFICATION_TYPE_COMMENT_REPLIED = 'comment_replied'.freeze
  NOTIFICATION_TYPE_QUESTION_ANSWERED = 'question_answered'.freeze
  NOTIFICATION_TYPE_ARGUMENT_DEBATE = 'argument_debate'.freeze
  NOTIFICATION_TYPE_UPVOTED_ARGUMENT = 'upvoted_argument'.freeze
  NOTIFICATION_TYPE_UPVOTED_QUESTION_ANSWER = 'upvoted_answer'.freeze
  NOTIFICATION_TYPE_DOWNVOTED_ARGUMENT = 'downvote_argument'.freeze
  NOTIFICATION_TYPE_DOWNVOTED_QUESTION_ANSWER = 'downvote_answer'.freeze
  NOTIFICATION_TYPE_LAYER_CREATED = 'layer_created'.freeze
  NOTIFICATION_TYPE_NONE  = 'none'.freeze
  NOTIFICATION_TYPE_DAILY  = 'daily'.freeze
  NOTIFICATION_TYPE_INSTANT  = 'instant'.freeze
  NOTIFICATION_TYPE_INVITE  = 'invite'.freeze
  NOTIFICATION_TYPE_JOIN_GROUP  = 'join_group'.freeze
  NOTIFICATION_TYPE_LEAVE_GROUP  = 'leave_group'.freeze
  NOTIFICATION_TYPE_GROUP_INVITE  = 'group_invite'.freeze
  NOTIFICATION_TYPE_GROUP_REQUEST = 'group_request'.freeze
  NOTIFICATION_TYPE_GROUP_REQUEST_ACCEPTED = 'group_request_accept'.freeze
  NOTIFICATION_TYPE_GROUP_REQUEST_REJECTED = 'group_request_rejected'.freeze

  ################################ relationships ############################
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true
  belongs_to :post, optional: true
  belongs_to :admin_notification, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(5) }

  def self.post(to:, from:, action:, notifiable:, post_id: nil, admin_notification_id: nil)
    recipients = Array.wrap(to)
    notifications = []
    Notification.transaction do
      notifications = recipients.uniq.each do |recipient|
        Notification.create(
          notifiable: notifiable,
          action: action,
          recipient: recipient,
          actor: from,
          post_id: post_id,
          admin_notification_id: admin_notification_id
        )
      end
    end
    notifications
  end
end
