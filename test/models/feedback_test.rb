require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Test User")
    feedback = Feedback.new(user: user, title: "Feedback Survey")

    assert feedback.valid?
  end

  test "should have many feedback_responses with dependent destroy" do
    feedback = Feedback.create(title: "Feedback Survey")
    response1 = FeedbackResponse.create(feedback: feedback, feedback_question: FeedbackQuestion.new)
    response2 = FeedbackResponse.create(feedback: feedback, feedback_question: FeedbackQuestion.new)

    assert_includes feedback.feedback_responses, response1
    assert_includes feedback.feedback_responses, response2

    assert_difference 'FeedbackResponse.count', -2 do
      feedback.destroy
    end
  end

  test "should accept nested attributes for feedback_responses" do
    feedback = Feedback.new(title: "Feedback Survey")
    feedback_params = {
      feedback_responses_attributes: [
        { feedback_question_id: 1, content: "Response 1" },
        { feedback_question_id: 2, content: "Response 2" }
      ]
    }

    feedback.update(feedback_params)

    assert_equal 2, feedback.feedback_responses.size
  end
end
