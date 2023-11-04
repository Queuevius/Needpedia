require 'test_helper'

class QuestionnaireTest < ActiveSupport::TestCase
  test 'should be valid with valid attributes' do
    questionnaire = Questionnaire.new(title: 'Sample Questionnaire')
    assert questionnaire.valid?
  end

  test 'should not be valid without a title' do
    questionnaire = Questionnaire.new
    assert_not questionnaire.valid?
  end

  test 'should have many questions' do
    association = Questionnaire.reflect_on_association(:questions)
    assert_equal :has_many, association.macro
  end

  test 'should have many user_questionnaires' do
    association = Questionnaire.reflect_on_association(:user_questionnaires)
    assert_equal :has_many, association.macro
  end

  test 'should have many users through user_questionnaires' do
    association = Questionnaire.reflect_on_association(:users)
    assert_equal :has_many, association.macro
  end
end
