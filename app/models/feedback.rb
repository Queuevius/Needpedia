class Feedback < ApplicationRecord
  belongs_to :user
  has_many :feedback_responses, dependent: :destroy
  accepts_nested_attributes_for :feedback_responses, allow_destroy: false, reject_if: :all_blank
end
