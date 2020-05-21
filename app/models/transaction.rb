class Transaction < ApplicationRecord

  ################################ Constants ############################

  TRANSACTION_TYPE_GIG = 'gig'.freeze
  TRANSACTION_TYPE_DEFAULT = 'default'.freeze
  TRANSACTION_TYPE_ADMIN = 'admin'.freeze
  TRANSACTION_TYPES = [
    TRANSACTION_TYPE_GIG,
    TRANSACTION_TYPE_DEFAULT,
    TRANSACTION_TYPE_ADMIN
  ].freeze

  ################################ Relationships ########################

  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :gig, optional: true

  ############################### Validations ###########################
  validates :amount, presence: true
  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }

  ############################### Scopes ################################

  ############################### Methods ################################
end
