require 'test_helper'

class FeedbackResponseTest < ActiveSupport::TestCase
  test "should belong to a feedback" do
    feedback = Feedback.create(title: "Feedback Survey")
    response = FeedbackResponse.new(feedback: feedback, feedback_question: FeedbackQuestion.new, feedback_question_option: FeedbackQuestionOption.new)

    assert response.valid?
  end

  test "should belong to a feedback_question" do
    feedback_question = FeedbackQuestion.create(question: "How satisfied are you?")
    response = FeedbackResponse.new(feedback: Feedback.new, feedback_question: feedback_question, feedback_question_option: FeedbackQuestionOption.new)

    assert response.valid?
  end

  test "should belong to a feedback_question_option (optional)" do
    response = FeedbackResponse.new(feedback: Feedback.new, feedback_question: FeedbackQuestion.new)

    assert response.valid?
  end
end
