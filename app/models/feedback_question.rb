class FeedbackQuestion < ApplicationRecord
  has_many :feedback_question_options, dependent: :destroy
end
