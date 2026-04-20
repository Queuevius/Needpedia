require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Sender User")
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    message = Message.new(user: user, receiver: receiver, conversation: conversation, content: "Hello, how are you?")

    assert message.valid?
  end

  test "should belong to a receiver (User)" do
    user = User.create(name: "Sender User")
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    message = Message.new(user: user, receiver: receiver, conversation: conversation, content: "Hello, how are you?")

    assert message.valid?
  end

  test "should belong to a conversation" do
    user = User.create(name: "Sender User")
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    message = Message.new(user: user, receiver: receiver, conversation: conversation, content: "Hello, how are you?")

    assert message.valid?
  end

  test "should have an 'unread' scope" do
    user = User.create(name: "Sender User")
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    message1 = Message.create(user: user, receiver: receiver, conversation: conversation, content: "Hello")
    message2 = Message.create(user: receiver, receiver: user, conversation: conversation, content: "Hi")

    unread_messages = Message.unread

    assert_includes unread_messages, message1
    assert_not_includes unread_messages, message2
  end

  test "should send an email notification after create" do
    sender = User.create(name: "Sender User", message_notifications: Notification::NOTIFICATION_TYPE_INSTANT)
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    message = Message.new(user: sender, receiver: receiver, conversation: conversation, content: "Hello")

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      message.send_email
    end
  end

  test "should not send an email notification if the sender is blocked by the receiver" do
    sender = User.create(name: "Sender User", message_notifications: Notification::NOTIFICATION_TYPE_INSTANT)
    receiver = User.create(name: "Receiver User")
    conversation = Conversation.create
    BlockedUser.create(user: receiver, block_user: sender)
    message = Message.new(user: sender, receiver: receiver, conversation: conversation, content: "Hello")

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      message.send_email
    end
  end
end
