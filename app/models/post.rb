class Post < ApplicationRecord
  include PublicActivity::Model
  has_rich_text :content
  acts_as_taggable_on :tags
  has_many_attached :images
  # after_save :clean_froala_link
  ################################ Constants ############################
  POST_TYPE_AREA = 'area'.freeze
  POST_TYPE_PROBLEM = 'problem'.freeze
  POST_TYPE_PROPOSAL = 'proposal'.freeze
  POST_TYPE_IDEA = 'idea'.freeze
  POST_TYPE_LAYER = 'layer'.freeze
  POST_TYPE_SOCIAL_MEDIA = 'social_media'.freeze
  POST_TYPES = [
    POST_TYPE_AREA,
    POST_TYPE_PROBLEM,
    POST_TYPE_PROPOSAL,
    POST_TYPE_IDEA,
    POST_TYPE_LAYER,
    POST_TYPE_SOCIAL_MEDIA
  ].freeze

  GENERAL_AREA = ENV['GENERAL_AREA_ID']
  GENERAL_PROBLEM = ENV['GENERAL_PROBLEM_ID']
  ################################ Relationships ########################
  belongs_to :user, optional: true
  belongs_to :parent_area, class_name: 'Post', foreign_key: :area_id, optional: true
  has_many :child_posts, class_name: 'Post', foreign_key: :area_id, dependent: :destroy

  belongs_to :problem, class_name: 'Post', foreign_key: :problem_id, optional: true
  has_many :ideas, class_name: 'Post', foreign_key: :problem_id, dependent: :destroy

  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_id, optional: true
  has_many :layers, class_name: 'Post', foreign_key: :post_id, dependent: :destroy

  has_many :comments, as: :commentable, dependent: :destroy

  has_many :flags, as: :flagable, dependent: :destroy

  has_many :likes, as: :likeable, dependent: :destroy

  has_many :shares, as: :shareable, dependent: :destroy

  has_many :post_tokens, dependent: :destroy

  has_many :user_posts, dependent: :destroy
  has_many :users, through: :user_posts, dependent: :destroy

  has_many :user_private_posts, dependent: :destroy
  has_many :private_users, through: :user_private_posts, source: :user, dependent: :destroy

  has_many :notifications, dependent: :destroy

  ############################### Validations ###########################
  validates :title, presence: true
  validates :post_type, presence: true, inclusion: { in: POST_TYPES }
  validates :area_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_PROBLEM || s.post_type == POST_TYPE_PROPOSAL }
  validates :problem_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_IDEA }
  # validates :post_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_LAYER }

  ############################### Scopes ################################

  # default_scope { where(disabled: false) }
  scope :posts_feed, -> { where(disabled: false).where.not('post_type IN (?)', [POST_TYPE_IDEA, POST_TYPE_LAYER]) }
  scope :area_posts, -> { where(post_type: POST_TYPE_AREA, disabled: false) }
  scope :problem_posts, -> { where(post_type: POST_TYPE_PROBLEM, disabled: false) }
  scope :proposal_posts, -> { where(post_type: POST_TYPE_PROPOSAL, disabled: false) }
  scope :idea_posts, -> { where(post_type: POST_TYPE_IDEA, disabled: false) }
  scope :layer_posts, -> { where(post_type: POST_TYPE_LAYER, disabled: false) }

  ############################### Methods ################################
  def parent_post_id
    area_id
  end

  def clean_froala_link
    body = self.content.body.to_s.remove("Powered by")
    self.update(content: body)
  end
end
