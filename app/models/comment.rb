class Comment < ApplicationRecord

  ################################ Relationships ########################
  # belongs_to :parent_post, class_name: 'Post', foreign_key: :post_id, optional: true
  # belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to  :parent, class_name: 'Comment', optional: true
  has_many    :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  has_many :flags, as: :flagable, dependent: :destroy
  validates_presence_of :body

  enum status: %i[active deleted]

  after_create :send_notification_to_users_on_comment, if: -> { parent_id.nil? && user_id != commentable.user_id }
  after_create :send_notification_to_users_on_reply, unless: -> { parent_id.nil? }
  after_update :send_notification_to_repliers_on_edit, if: -> { parent_id.nil? && active? && replies.active.present? }
  after_update :send_notification_to_repliers_on_delete, if: -> { parent_id.nil? && deleted? && replies.active.present? }

  def send_notification_to_users_on_comment
    Notification.post(from: user, notifiable: user, to: commentable.user, action: Notification::NOTIFICATION_TYPE_COMMENT_CREATED, post_id: commentable_type == 'Post' ? commentable_id : nil)
  end

  def send_notification_to_users_on_reply
    Notification.post(from: user, notifiable: user, to: parent.user, action: Notification::NOTIFICATION_TYPE_COMMENT_REPLIED, post_id: commentable_type == 'Post' ? commentable_id : nil)
  end

  def send_notification_to_repliers_on_edit
    Notification.post(from: user, notifiable: user, to: User.where(id: replies.active.where.not(user_id: user_id).pluck(:user_id)), action: Notification::NOTIFICATION_TYPE_COMMENT_EDITED, post_id: commentable_type == 'Post' ? commentable_id : nil)
  end

  def send_notification_to_repliers_on_delete
    Notification.post(from: user, notifiable: user, to: User.where(id: replies.active.where.not(user_id: user_id).pluck(:user_id)), action: Notification::NOTIFICATION_TYPE_COMMENT_DELETED, post_id: commentable_type == 'Post' ? commentable_id : nil)
  end
end
