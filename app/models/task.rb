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

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 999.99 }

  # Impact reward: exactly one ledger row per (assignee, task), keyed on
  # task_id because title is mutable. find_or_create makes re-saves and
  # reopen->complete cycles idempotent; the saved_change guard means only a
  # real transition fires, not every update touch.
  after_update :award_completion_impact,
               if: -> { saved_change_to_status? && status == 'Completed Tasks' && assignee_id.present? }

  private

  def award_completion_impact
    Impact.find_or_create_by!(user_id: assignee_id, task_id: id) do |impact|
      impact.description = "Completed: #{title}"
      impact.badge = 'Task Completed'
    end
  end
end
