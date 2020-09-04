class PostToken < ApplicationRecord
  has_rich_text :content

  ################################ Relationships ########################
  belongs_to :user
  belongs_to :post
  has_many :token_ans_debate, dependent: :destroy

  ################################ Constants ############################
  TOKEN_TYPE_NOTE = 'note'.freeze
  TOKEN_TYPE_QUESTION = 'question'.freeze
  TOKEN_TYPE_DEBATE = 'debate'.freeze
  TOKEN_TYPES = [
      TOKEN_TYPE_NOTE,
      TOKEN_TYPE_QUESTION,
      TOKEN_TYPE_DEBATE
  ].freeze

  ################################# Scopes #############################
  scope :note_tokens, -> { where(post_token_type: TOKEN_TYPE_NOTE) }
  scope :question_tokens, -> { where(post_token_type: TOKEN_TYPE_QUESTION) }
  scope :debate_tokens, -> { where(post_token_type: TOKEN_TYPE_DEBATE) }
end
