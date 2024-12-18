class Task < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many_attached :images
  STATUSES = %w[Casual Pressing Urgent].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 999.99 }
end
