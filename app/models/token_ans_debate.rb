class TokenAnsDebate < ApplicationRecord
  has_rich_text :content

  ################################ Relationships ########################
  belongs_to :post_token
  belongs_to :user
  belongs_to :post
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :flags, as: :flagable, dependent: :destroy

  ################################ Constants ############################
  DEBATE_TYPE_AGAINST = 'against'.freeze
  DEBATE_TYPE_FOR = 'for'.freeze
  DEBATE_TYPE_NEUTRAL = 'neutral'.freeze
  DEBATE_TYPES = [
      DEBATE_TYPE_AGAINST,
      DEBATE_TYPE_FOR,
      DEBATE_TYPE_NEUTRAL
  ].freeze
  ################################ Callbacks ############################

  after_create :send_notification_on_answer, if: -> { post_token.post_token_type == PostToken::TOKEN_TYPE_QUESTION && user_id != post_token.user_id }
  after_create :send_notification_on_debate_argument, if: -> { post_token.post_token_type == PostToken::TOKEN_TYPE_DEBATE && user_id != post_token.user_id }

  def send_notification_on_answer
    Notification.post(from: user, notifiable: user, to: post_token.user, action: Notification::NOTIFICATION_TYPE_QUESTION_ANSWERED, post_id: post_token.post_id)
  end

  def send_notification_on_debate_argument
    Notification.post(from: user, notifiable: user, to: post_token.user, action: Notification::NOTIFICATION_TYPE_ARGUMENT_DEBATE, post_id: post_token.post_id)
  end
end
