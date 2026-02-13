require 'test_helper'

class UserQuestionnaireTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @questionnaire = Questionnaire.create(title: 'Sample Questionnaire')
  end

  test 'should be valid with valid attributes' do
    user_questionnaire = UserQuestionnaire.new(user: @user, questionnaire: @questionnaire)
    assert user_questionnaire.valid?
  end

  test 'should belong to a user' do
    association = UserQuestionnaire.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a questionnaire' do
    association = UserQuestionnaire.reflect_on_association(:questionnaire)
    assert_equal :belongs_to, association.macro
  end
end
