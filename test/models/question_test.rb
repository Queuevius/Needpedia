require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  def setup
    @questionnaire = Questionnaire.create(title: 'Sample Questionnaire')
  end

  test 'should be valid with valid attributes' do
    question = Question.new(content: 'What is your favorite color?', questionnaire: @questionnaire)
    assert question.valid?
  end

  test 'should not be valid without content' do
    question = Question.new(questionnaire: @questionnaire)
    assert_not question.valid?
  end

  test 'should belong to a questionnaire' do
    association = Question.reflect_on_association(:questionnaire)
    assert_equal :belongs_to, association.macro
  end

  test 'should have many answers' do
    association = Question.reflect_on_association(:answers)
    assert_equal :has_many, association.macro
  end
end
