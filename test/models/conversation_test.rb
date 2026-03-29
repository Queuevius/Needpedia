# test/models/conversation_test.rb

require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  test "should have many messages with dependent destroy" do
    conversation = Conversation.create
    message1 = Message.create(conversation: conversation, content: "Hello")
    message2 = Message.create(conversation: conversation, content: "Hi")

    assert_includes conversation.messages, message1
    assert_includes conversation.messages, message2

    assert_difference 'Message.count', -2 do
      conversation.destroy
    end
  end

  test "should have many user_conversations with dependent destroy" do
    conversation = Conversation.create
    user1 = User.create(name: "User 1")
    user2 = User.create(name: "User 2")
    user_conversation1 = UserConversation.create(conversation: conversation, user: user1)
    user_conversation2 = UserConversation.create(conversation: conversation, user: user2)

    assert_includes conversation.user_conversations, user_conversation1
    assert_includes conversation.user_conversations, user_conversation2

    assert_difference 'UserConversation.count', -2 do
      conversation.destroy
    end
  end

  test "should have many users through user_conversations" do
    conversation = Conversation.create
    user1 = User.create(name: "User 1")
    user2 = User.create(name: "User 2")
    user_conversation1 = UserConversation.create(conversation: conversation, user: user1)
    user_conversation2 = UserConversation.create(conversation: conversation, user: user2)

    assert_includes conversation.users, user1
    assert_includes conversation.users, user2
  end
end
