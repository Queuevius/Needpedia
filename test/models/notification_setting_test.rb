require 'test_helper'

class NotificationSettingTest < ActiveSupport::TestCase
  test "should belong to a user" do
    user = User.create(name: "Test User")
    notification_setting = NotificationSetting.new(user: user, post: Post.new)

    assert notification_setting.valid?
  end

  test "should belong to a post" do
    user = User.create(name: "Test User")
    post = Post.create(title: "Test Post")
    notification_setting = NotificationSetting.new(user: user, post: post)

    assert notification_setting.valid?
  end
end
