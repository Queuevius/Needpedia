class Task < ApplicationRecord
  belongs_to :group
  belongs_to :user
  belongs_to :assignee, class_name: 'User', optional: true
  has_many_attached :images
  has_many :comments, as: :commentable, dependent: :destroy
  STATUSES = [
    'Available Tasks',
    'Under Progress',
    'Completed Tasks'
  ].freeze
  PRIORITIES = %w[Casual Pressing Urgent].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 999.99 }
end
