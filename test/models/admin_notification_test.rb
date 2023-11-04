require 'test_helper'

class AdminNotificationTest < ActiveSupport::TestCase
  test "valid notification with all audience" do
    notification = AdminNotification.new(audience: AdminNotification::ALL)
    assert notification.valid?
  end

  test "notification for guests scope" do
    notification = AdminNotification.create(audience: AdminNotification::GUESTS)
    assert_includes AdminNotification.for_guests, notification
  end
end
