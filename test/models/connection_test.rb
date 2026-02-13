require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  test "should validate unique following" do
    user_a = User.create(name: "User A")
    user_b = User.create(name: "User B")

    connection = Connection.new(user: user_a, friend: user_b)
    connection.valid?

    assert_empty connection.errors[:followings]

    # Create a duplicate connection
    duplicate_connection = Connection.new(user: user_b, friend: user_a)
    duplicate_connection.valid?

    assert_includes duplicate_connection.errors[:followings], 'This connection already exists.'
  end
end
