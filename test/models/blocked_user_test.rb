require 'test_helper'

class BlockedUserTest < ActiveSupport::TestCase
  test "should be valid" do
    user = User.create(name: "User A")
    block_user = User.create(name: "User B")
    blocked_user = BlockedUser.new(user: user, block_user: block_user)
    assert blocked_user.valid?
  end

  test "should belong to a user" do
    block_user = User.create(name: "User B")
    blocked_user = BlockedUser.new(block_user: block_user)
    assert_not blocked_user.valid?
    assert_includes blocked_user.errors[:user], "must exist"
  end

  test "should belong to a block_user" do
    user = User.create(name: "User A")
    blocked_user = BlockedUser.new(user: user)
    assert_not blocked_user.valid?
    assert_includes blocked_user.errors[:block_user], "must exist"
  end
end
