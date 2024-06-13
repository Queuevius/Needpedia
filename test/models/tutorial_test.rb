require 'test_helper'

class TutorialTest < ActiveSupport::TestCase
  def setup
    @tutorial = Tutorial.new(content: 'Sample tutorial content')
    @user1 = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @user2 = User.create(username: 'user2', email: 'user2@example.com', password: 'password')
  end

  test 'should be valid with valid attributes' do
    assert @tutorial.valid?
  end

  test 'after_create and after_update should update user_tutorials for all users' do
    user_tutorial = @user1.user_tutorials.build(link: @tutorial.link, content: nil, viewed: false)
    user_tutorial.save

    user_tutorial = @user2.user_tutorials.build(link: @tutorial.link, content: nil, viewed: false)
    user_tutorial.save

    assert_difference('UserTutorial.count', 2) do
      @tutorial.save
    end

    user_tutorial1 = UserTutorial.find_by(user: @user1, link: @tutorial.link)
    user_tutorial2 = UserTutorial.find_by(user: @user2, link: @tutorial.link)

    assert_equal 'Sample tutorial content', user_tutorial1.content.to_plain_text
    assert_equal 'Sample tutorial content', user_tutorial2.content.to_plain_text
    assert_not user_tutorial1.viewed
    assert_not user_tutorial2.viewed

    @tutorial.update(content: 'Updated tutorial content')

    user_tutorial1.reload
    user_tutorial2.reload

    assert_equal 'Updated tutorial content', user_tutorial1.content.to_plain_text
    assert_equal 'Updated tutorial content', user_tutorial2.content.to_plain_text
    assert_not user_tutorial1.viewed
    assert_not user_tutorial2.viewed
  end
end
