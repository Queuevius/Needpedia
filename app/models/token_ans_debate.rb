class TokenAnsDebate < ApplicationRecord
  has_rich_text :content

  ################################ Relationships ########################
  belongs_to :post_token
  belongs_to :user
  belongs_to :post

  ################################ Constants ############################
  DEBATE_TYPE_AGAINST = 'against'.freeze
  DEBATE_TYPE_FOR = 'for'.freeze
  DEBATE_TYPE_NEUTRAL = 'neutral'.freeze
  DEBATE_TYPES = [
      DEBATE_TYPE_AGAINST,
      DEBATE_TYPE_FOR,
      DEBATE_TYPE_NEUTRAL
  ].freeze
end
