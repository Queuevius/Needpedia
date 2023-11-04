require 'test_helper'

class FlagTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Test User")
    flag = Flag.new(user: user, reason: "Inappropriate content")

    assert flag.valid?
  end

  test "should belong to a flagable object (polymorphic)" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    flag = Flag.new(flagable: post, user: user, reason: "Inappropriate content")

    assert flag.valid?
  end

  test "should have a rich text reason association" do
    flag = Flag.new(reason: ActionText::Content.new("Inappropriate content"))

    assert flag.valid?
  end

  test "should require presence of reason" do
    flag = Flag.new

    assert_not flag.valid?
    assert_includes flag.errors[:reason], "can't be blank"
  end

  test "should send notification on downvote for TokenAnsDebate" do
    debate = TokenAnsDebate.create(title: "Debate Title")
    user = User.create(name: "Test User")
    flag = Flag.new(flagable: debate, user: user, reason: "Inappropriate content")

    assert flag.valid?
    assert_difference 'Notification.count', 1 do
      flag.send_notification_on_downvote_token_debate
    end
  end

  test "should send email for Post" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    flag = Flag.new(flagable: post, user: user, reason: "Inappropriate content")

    assert flag.valid?
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      flag.send_email
    end
  end
end
