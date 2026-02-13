require 'test_helper'

class UserTutorialTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
  end

  test 'should be valid with valid attributes' do
    user_tutorial = UserTutorial.new(user: @user)
    assert user_tutorial.valid?
  end

  test 'should belong to a user' do
    association = UserTutorial.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end
end
