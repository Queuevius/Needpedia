class FeedbackResponse < ApplicationRecord
  belongs_to :feedback
  belongs_to :feedback_question
  belongs_to :feedback_question_option, optional: true
end
