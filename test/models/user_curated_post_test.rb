require 'test_helper'

class UserCuratedPostTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user)
  end

  test 'should be valid with valid attributes' do
    user_curated_post = UserCuratedPost.new(user: @user, post: @post)
    assert user_curated_post.valid?
  end

  test 'should belong to a user' do
    association = UserCuratedPost.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a post' do
    association = UserCuratedPost.reflect_on_association(:post)
    assert_equal :belongs_to, association.macro
  end
end
