class AdminNotification < ApplicationRecord
  has_rich_text :message
  ALL = 'All'.freeze
  NEW_COMERS = 'New Comers'.freeze
  GUESTS = 'Guests'.freeze
  TYPES = [
    ALL,
    NEW_COMERS,
    GUESTS
  ].freeze

  scope :for_guests, -> { where(audience: GUESTS) }
  scope :for_all, -> { where(audience: ALL) }
  scope :for_new_comers, -> { where(audience: NEW_COMERS) }
end
