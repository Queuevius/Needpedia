class Gig < ApplicationRecord
  has_rich_text :body
  has_many_attached :images
  after_create :activate_gig

  ################################ Constants ############################

  GIG_STATUS_PENDING = 'pending'.freeze
  GIG_STATUS_ACTIVE = 'active'.freeze
  GIG_STATUS_DISABLE = 'disable'.freeze
  GIG_STATUS_PROGRESS = 'progress'.freeze
  GIG_STATUS_AWARDED = 'awarded'.freeze
  TRANSACTION_TYPES = [
    GIG_STATUS_PENDING,
    GIG_STATUS_ACTIVE,
    GIG_STATUS_DISABLE,
    GIG_STATUS_PROGRESS,
    GIG_STATUS_AWARDED
  ].freeze

  ################################ Relationships ########################
  belongs_to :user, optional: true
  has_one :credit_transaction, class_name: 'Transaction'

  has_many :user_gigs
  has_many :users, through: :user_gigs, dependent: :destroy

  ############################### Validations ###########################
  validates :title, presence: true
  validates :area_tag, presence: true
  validates :body, presence: true
  validates :amount, presence: true
  validate :correct_amount
  validates :images, blob: { content_type: ['image/jpg', 'image/jpeg', 'image/png'], size_range: 1..3.megabytes }

  ############################### Scopes ################################

  ############################### methods ################################
  def activate_gig
    update(status: GIG_STATUS_ACTIVE) if user.credit_hours.positive?
  end

  def correct_amount
    errors.add(:amount, 'can not be greater than available credit') if amount >= user.credit_hours
  end
end
