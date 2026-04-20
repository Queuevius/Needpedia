require 'test_helper'

class UserConversationTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @user2 = User.create(username: 'user2', email: 'user2@example.com', password: 'password')
    @conversation = Conversation.create(title: 'Sample Conversation')
  end

  test 'should be valid with valid attributes' do
    user_conversation = UserConversation.new(user: @user1, conversation: @conversation)
    assert user_conversation.valid?
  end

  test 'should belong to a user' do
    association = UserConversation.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a conversation' do
    association = UserConversation.reflect_on_association(:conversation)
    assert_equal :belongs_to, association.macro
  end
end
