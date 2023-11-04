require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  test "should be valid" do
    user = User.create(name: "John")
    question = Question.create(title: "Example Question")
    answer = Answer.new(user: user, question: question, content: "This is an answer.")
    assert answer.valid?
  end

  test "should belong to a user" do
    answer = Answer.new(question: Question.new, content: "This is an answer.")
    assert_not answer.valid?
    assert_includes answer.errors[:user], "must exist"
  end

  test "should belong to a question" do
    answer = Answer.new(user: User.new, content: "This is an answer.")
    assert_not answer.valid?
    assert_includes answer.errors[:question], "must exist"
  end
end
