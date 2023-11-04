require 'test_helper'

class InterestedUserTest < ActiveSupport::TestCase
  test "should belong to a parent (optional)" do
    parent = InterestedUser.create
    interested_user = InterestedUser.new(parent: parent, post: Post.new, user: User.new, body: "Interested")

    assert interested_user.valid?
  end

  test "should have many replies with dependent destroy" do
    parent = InterestedUser.create
    interested_user1 = InterestedUser.create(parent: parent, post: Post.new, user: User.new, body: "Reply 1")
    interested_user2 = InterestedUser.create(parent: parent, post: Post.new, user: User.new, body: "Reply 2")

    assert_includes parent.replies, interested_user1
    assert_includes parent.replies, interested_user2

    assert_difference 'InterestedUser.count', -3 do
      parent.destroy
    end
  end

  test "should belong to a post" do
    post = Post.create(title: "Test Post")
    interested_user = InterestedUser.new(post: post, user: User.new, body: "Interested")

    assert interested_user.valid?
  end

  test "should belong to a user" do
    user = User.create(name: "Test User")
    interested_user = InterestedUser.new(user: user, post: Post.new, body: "Interested")

    assert interested_user.valid?
  end

  test "should have a maximum body length of 350 characters" do
    interested_user = InterestedUser.new(body: "a" * 350)

    assert interested_user.valid?

    interested_user.body = "a" * 351
    assert_not interested_user.valid?
    assert_includes interested_user.errors[:body], "is too long (maximum is 350 characters)"
  end
end
