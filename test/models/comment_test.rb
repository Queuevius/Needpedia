require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "should be valid" do
    comment = Comment.new(body: "This is a comment")
    assert comment.valid?
  end

  test "should have associations" do
    comment = Comment.new
    assert_respond_to comment, :user
    assert_respond_to comment, :commentable
    assert_respond_to comment, :parent
    assert_respond_to comment, :replies
    assert_respond_to comment, :flags
  end

  test "should send notification to users on comment creation" do
    user = User.create(name: "User A")
    post = Post.create(title: "Example Post", user: user)
    comment = Comment.create(user: user, commentable: post, body: "This is a comment")
    
    assert_not_empty Notification.where(from: user, notifiable: user, to: post.user, action: Notification::NOTIFICATION_TYPE_COMMENT_CREATED)
  end

  test "should send notification to users on reply creation" do
    user_a = User.create(name: "User A")
    user_b = User.create(name: "User B")
    post = Post.create(title: "Example Post", user: user_a)
    comment = Comment.create(user: user_b, commentable: post, body: "This is a comment")

    reply = Comment.create(user: user_a, commentable: post, parent: comment, body: "This is a reply")
    
    assert_not_empty Notification.where(from: user_a, notifiable: user_a, to: user_b, action: Notification::NOTIFICATION_TYPE_COMMENT_REPLIED)
  end
end
