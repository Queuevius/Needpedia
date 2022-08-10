class Flag < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :flagable, polymorphic: true
  belongs_to :user
  ################################ Callbacks ########################
  after_create :send_notification_on_downvote_token_debate, if: -> { flagable_type == 'TokenAnsDebate' && user_id != flagable.user_id }
  after_create :send_email

  def send_notification_on_downvote_token_debate
    if flagable.debate_type.present?
      Notification.post(from: user, notifiable: user, to: flagable.user, action: Notification::NOTIFICATION_TYPE_DOWNVOTED_ARGUMENT, post_id: flagable.post_id)
    else
      Notification.post(from: user, notifiable: user, to: flagable.user, action: Notification::NOTIFICATION_TYPE_DOWNVOTED_QUESTION_ANSWER, post_id: flagable.post_id)
    end
  end

  def send_email
    post = flagable
    users = post.users
    users.each do |u|
      next if u.daily_notifications? || !u.track_notifications?

      UserMailer.send_tracking_email(actor: user, receiver: u, post: post).deliver_now
    end
  end
end
