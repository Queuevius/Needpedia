# test/models/token_ans_debate_test.rb

require 'test_helper'

class TokenAnsDebateTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @user2 = User.create(username: 'user2', email: 'user2@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user1)
    @post_token = PostToken.create(post: @post, user: @user1, post_token_type: PostToken::TOKEN_TYPE_QUESTION)
  end

  test 'should be valid with valid attributes' do
    token_ans_debate = TokenAnsDebate.new(post_token: @post_token, user: @user2, content: 'This is a valid answer/debate.')
    assert token_ans_debate.valid?
  end

  test 'should not be valid without a post_token' do
    token_ans_debate = TokenAnsDebate.new(user: @user2, content: 'Missing post token.')
    assert_not token_ans_debate.valid?
  end

  test 'should not be valid without a user' do
    token_ans_debate = TokenAnsDebate.new(post_token: @post_token, content: 'Missing user.')
    assert_not token_ans_debate.valid?
  end

  test 'should have a DEBATE_TYPES constant' do
    assert_equal ['against', 'for', 'neutral'], TokenAnsDebate::DEBATE_TYPES
  end

  test 'should belong to a post_token' do
    association = TokenAnsDebate.reflect_on_association(:post_token)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a user' do
    association = TokenAnsDebate.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should have many likes with dependent: destroy' do
    association = TokenAnsDebate.reflect_on_association(:likes)
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test 'should have many flags with dependent: destroy' do
    association = TokenAnsDebate.reflect_on_association(:flags)
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test 'send_notification_on_answer should create a notification for question answered' do
    assert_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Answer to a question.')
    end
  end

  test 'send_notification_on_answer should not create a notification if the post_token_type is not TOKEN_TYPE_QUESTION' do
    @post_token.update(post_token_type: PostToken::TOKEN_TYPE_DEBATE)

    assert_no_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Answer to a debate argument.')
    end
  end

  test 'send_notification_on_answer should not create a notification if the user is the same as the post_token user' do
    @post_token.update(user: @user2)

    assert_no_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Answer to a question.')
    end
  end

  test 'send_notification_on_debate_argument should create a notification for debate argument' do
    @post_token.update(post_token_type: PostToken::TOKEN_TYPE_DEBATE)

    assert_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Debate argument.')
    end
  end

  test 'send_notification_on_debate_argument should not create a notification if the post_token_type is not TOKEN_TYPE_DEBATE' do
    assert_no_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Debate argument for a question.')
    end
  end

  test 'send_notification_on_debate_argument should not create a notification if the user is the same as the post_token user' do
    @post_token.update(user: @user2)

    assert_no_difference('Notification.count') do
      TokenAnsDebate.create(post_token: @post_token, user: @user2, content: 'Debate argument.')
    end
  end
end
