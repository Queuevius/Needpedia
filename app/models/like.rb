class Like < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  ################################ Callbacks ########################
  after_create :send_notification_on_upvote_token_debate, if: -> { likeable_type == 'TokenAnsDebate' && user_id != likeable.user_id }

  def send_notification_on_upvote_token_debate
    if likeable.debate_type.present?
      Notification.post(from: user, notifiable: user, to: likeable.user, action: Notification::NOTIFICATION_TYPE_UPVOTED_ARGUMENT, post_id: likeable.post_id)
    else
      Notification.post(from: user, notifiable: user, to: likeable.user, action: Notification::NOTIFICATION_TYPE_UPVOTED_QUESTION_ANSWER, post_id: likeable.post_id)
    end
  end
end
