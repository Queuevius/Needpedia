require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  test "should belong to a likeable object (polymorphic)" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    like = Like.new(likeable: post, user: user)

    assert like.valid?
  end

  test "should have a rich text reason association" do
    like = Like.new
    like.reason = ActionText::Content.new("Reason for liking")

    assert like.valid?
  end

  test "should require presence of likeable" do
    like = Like.new(user: User.new)
    assert_not like.valid?
    assert_includes like.errors[:likeable], "must exist"
  end

  test "should require presence of user" do
    like = Like.new(likeable: Post.new)
    assert_not like.valid?
    assert_includes like.errors[:user], "must exist"
  end

  test "should send notification on upvote for TokenAnsDebate" do
    debate = TokenAnsDebate.create(title: "Debate Title")
    user = User.create(name: "Test User")
    like = Like.new(likeable: debate, user: user)

    assert like.valid?
    assert_difference 'Notification.count', 1 do
      like.send_notification_on_upvote_token_debate
    end
  end

  test "should send email for Post" do
    post = Post.create(title: "Test Post")
    user = User.create(name: "Test User")
    like = Like.new(likeable: post, user: user)

    assert like.valid?
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      like.send_email
    end
  end
end
