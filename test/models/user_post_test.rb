require 'test_helper'

class UserPostTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user)
  end

  test 'should be valid with valid attributes' do
    user_post = UserPost.new(user: @user, post: @post)
    assert user_post.valid?
  end

  test 'should belong to a user' do
    association = UserPost.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a post' do
    association = UserPost.reflect_on_association(:post)
    assert_equal :belongs_to, association.macro
  end
end
