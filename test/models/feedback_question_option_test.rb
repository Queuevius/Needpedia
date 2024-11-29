require 'test_helper'

class FeedbackQuestionOptionTest < ActiveSupport::TestCase
  test "should belong to a feedback_question" do
    feedback_question = FeedbackQuestion.create(question: "How satisfied are you?")
    option = FeedbackQuestionOption.new(feedback_question: feedback_question)

    assert option.valid?
  end

  test "should require presence of feedback_question" do
    option = FeedbackQuestionOption.new

    assert_not option.valid?
    assert_includes option.errors[:feedback_question], "must exist"
  end
end
