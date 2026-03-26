require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Test User")
    device = Device.new(user: user)

    assert device.valid?
  end

  test "should require presence of user" do
    device = Device.new

    assert_not device.valid?
    assert_includes device.errors[:user], "must exist"
  end
end
