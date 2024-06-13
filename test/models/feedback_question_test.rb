require 'test_helper'

class FeedbackQuestionTest < ActiveSupport::TestCase
  test "should have many feedback_question_options with dependent destroy" do
    feedback_question = FeedbackQuestion.create(question: "How satisfied are you?")
    option1 = FeedbackQuestionOption.create(feedback_question: feedback_question, option_text: "Very satisfied")
    option2 = FeedbackQuestionOption.create(feedback_question: feedback_question, option_text: "Satisfied")

    assert_includes feedback_question.feedback_question_options, option1
    assert_includes feedback_question.feedback_question_options, option2

    assert_difference 'FeedbackQuestionOption.count', -2 do
      feedback_question.destroy
    end
  end
end
