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

  ############################### Scopes ################################

  ############################### methods ################################
  def activate_gig
    update(status: GIG_STATUS_ACTIVE) if user.credit_hours.positive?
  end
end
