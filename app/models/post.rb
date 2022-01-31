class Post < ApplicationRecord
  include PublicActivity::Model
  has_rich_text :content
  has_one :content, class_name: 'ActionText::RichText', as: :record
  acts_as_taggable_on :tags, :resource_tags
  has_many_attached :images
  # after_save :clean_froala_link
  ################################ Constants ############################
  POST_TYPE_SUBJECT = 'subject'.freeze
  POST_TYPE_PROBLEM = 'problem'.freeze
  POST_TYPE_IDEA = 'idea'.freeze
  POST_TYPE_LAYER = 'layer'.freeze
  POST_TYPE_SOCIAL_MEDIA = 'social_media'.freeze
  POST_TYPE_WIKI_POSTS_ONLY = 'All Wiki Posts'.freeze
  POST_TYPE_HAVE = 'have'.freeze
  POST_TYPE_WANT = 'want'.freeze
  POST_TYPES = [
    POST_TYPE_SUBJECT,
    POST_TYPE_PROBLEM,
    POST_TYPE_IDEA,
    POST_TYPE_LAYER,
    POST_TYPE_SOCIAL_MEDIA,
    POST_TYPE_HAVE,
    POST_TYPE_WANT
  ].freeze

  CORE_POST_TYPES = [
    POST_TYPE_SUBJECT,
    POST_TYPE_PROBLEM,
    POST_TYPE_IDEA
  ].freeze

  TYPES_FOR_SEARCH = [POST_TYPE_WIKI_POSTS_ONLY] + POST_TYPES + ['All']

  GENERAL_AREA = ENV['GENERAL_AREA_ID']
  GENERAL_PROBLEM = ENV['GENERAL_PROBLEM_ID']
  ################################ Relationships ########################
  belongs_to :user, optional: true
  belongs_to :parent_subject, class_name: 'Post', foreign_key: :subject_id, optional: true
  has_many :child_posts, class_name: 'Post', foreign_key: :subject_id, dependent: :destroy

  belongs_to :problem, class_name: 'Post', foreign_key: :problem_id, optional: true
  has_many :ideas, class_name: 'Post', foreign_key: :problem_id, dependent: :destroy

  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_id, optional: true
  belongs_to :posted_to, class_name: 'User', foreign_key: :posted_to_id, optional: true
  has_many :layers, class_name: 'Post', foreign_key: :post_id, dependent: :destroy

  has_many :comments, as: :commentable, dependent: :destroy

  has_many :flags, as: :flagable, dependent: :destroy

  has_many :likes, as: :likeable, dependent: :destroy

  has_many :ratings, as: :rateable, dependent: :destroy

  has_many :shares, as: :shareable, dependent: :destroy

  has_many :post_tokens, dependent: :destroy

  has_many :user_posts, dependent: :destroy
  has_many :users, through: :user_posts, dependent: :destroy

  has_many :user_private_posts, dependent: :destroy
  has_many :private_users, through: :user_private_posts, source: :user, dependent: :destroy

  has_many :user_curated_posts, dependent: :destroy
  has_many :curated_users, through: :user_curated_posts, source: :user, dependent: :destroy

  has_many :notifications, dependent: :destroy
  has_many :notification_settings, dependent: :destroy

  ############################### Validations ###########################
  validates :title, presence: true
  validates :post_type, presence: true, inclusion: { in: POST_TYPES }
  validates :subject_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_PROBLEM }
  validates :problem_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_IDEA }
  validate :lat_is_present
  validate :long_is_present
  # validates :post_id, presence: true, if: proc { |s| s.post_type == POST_TYPE_LAYER }

  ############################### Scopes ################################

  # default_scope { where(disabled: false) }
  scope :posts_feed, -> { where(disabled: false).where.not('post_type IN (?)', [POST_TYPE_IDEA, POST_TYPE_LAYER]) }
  scope :area_posts, -> { where(post_type: POST_TYPE_SUBJECT, disabled: false) }
  scope :problem_posts, -> { where(post_type: POST_TYPE_PROBLEM, disabled: false) }
  scope :idea_posts, -> { where(post_type: POST_TYPE_IDEA, disabled: false) }
  scope :layer_posts, -> { where(post_type: POST_TYPE_LAYER, disabled: false) }
  scope :geo_maxing_posts, -> { where(geo_maxing: true) }

  ################################ Callbacks ########################
  after_create :send_notification, if: -> { post_type == Post::POST_TYPE_LAYER || post_type.in?(CORE_POST_TYPES) }
  after_create :send_notification_to_posted_to_user, if: -> { posted_to_id.present? }
  after_create :send_notification_on_layer_create, if: -> { post_type == Post::POST_TYPE_LAYER && post_id.present? && parent_post.tracking_enabled? }
  ############################### Methods ################################
  def parent_post_id
    subject_id
  end

  def clean_froala_link
    body = self.content.body.to_s.remove("Powered by")
    self.update(content: body)
  end

  def type_of?(type)
    post_type == type
  end

  def send_notification_to_posted_to_user
    Notification.post(from: user, notifiable: user, to: posted_to, action: Notification::NOTIFICATION_TYPE_POST_CREATED, post_id: id)
  end

  def send_notification_on_layer_create
    Notification.post(from: user, notifiable: user, to: parent_post.user, action: Notification::NOTIFICATION_TYPE_LAYER_CREATED, post_id: id)
  end

  def send_notification
    service = NotificationService.new(self, user)
    service.send
  end

  def tracking_enabled?
    UserPost.where(user_id: user_id, post_id: id).exists?
  end

  def lat_is_present
    errors.add(:base, 'Latitude cant be blank') if lat.blank? && geo_maxing
  end

  def long_is_present
    errors.add(:base, 'Longitude cant be blank, please select a location on map for GeoMaxing post') if long.blank? && geo_maxing
  end
end
