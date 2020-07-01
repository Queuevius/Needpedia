class ConnectionRequest < ApplicationRecord
  belongs_to :user

  ################################ Constants ############################

  CONNECTION_STATUS_PENDING = 'pending'.freeze

  CONNECTION_TYPES = [
    CONNECTION_STATUS_PENDING
  ].freeze

end
