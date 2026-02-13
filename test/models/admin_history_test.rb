require 'test_helper'

class AdminHistoryTest < ActiveSupport::TestCase
  test "should be valid" do
    admin_history = AdminHistory.new
    assert_not admin_history.valid?
  end

  test "belongs to a user" do
    user = User.create(username: "testuser")
    admin_history = AdminHistory.new(user: user)
    assert_equal user, admin_history.user
  end
end
