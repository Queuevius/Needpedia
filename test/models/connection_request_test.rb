require 'test_helper'

class ConnectionRequestTest < ActiveSupport::TestCase
  test "should be valid" do
    user = User.create(name: "John")
    connection_request = ConnectionRequest.new(user: user)
    assert connection_request.valid?
  end

  test "should belong to a user" do
    connection_request = ConnectionRequest.new
    assert_not connection_request.valid?
    assert_includes connection_request.errors[:user], "must exist"
  end

  test "should have connection status constants" do
    assert_equal "pending", ConnectionRequest::CONNECTION_STATUS_PENDING
  end

  test "should have connection types" do
    assert_includes ConnectionRequest::CONNECTION_TYPES, "pending"
  end
end
