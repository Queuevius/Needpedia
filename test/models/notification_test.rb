require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "should define the notification types as constants" do
    assert_equal "gig_accepted", Notification::NOTIFICATION_TYPE_ACCEPTED
    assert_equal "gig_awarded", Notification::NOTIFICATION_TYPE_AWARDED
    # Add similar assertions for other notification types
  end

  test "should belong to a recipient (User)" do
    user = User.create(name: "Recipient User")
    notification = Notification.new(recipient: user, actor: User.new, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_CREATED)

    assert notification.valid?
  end

  test "should belong to an actor (User)" do
    recipient = User.create(name: "Recipient User")
    notification = Notification.new(recipient: User.new, actor: recipient, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_CREATED)

    assert notification.valid?
  end

  test "should belong to a notifiable object (polymorphic)" do
    post = Post.create(title: "Test Post")
    notification = Notification.new(recipient: User.new, actor: User.new, notifiable: post, action: Notification::NOTIFICATION_TYPE_POST_CREATED)

    assert notification.valid?
  end

  test "should belong to a post (optional)" do
    post = Post.create(title: "Test Post")
    notification = Notification.new(recipient: User.new, actor: User.new, notifiable: post, action: Notification::NOTIFICATION_TYPE_POST_CREATED)

    assert notification.valid?
  end

  test "should belong to an admin_notification (optional)" do
    admin_notification = AdminNotification.create(message: "Admin Message")
    notification = Notification.new(recipient: User.new, actor: User.new, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_ADMIN_NOTIFICATION, admin_notification: admin_notification)

    assert notification.valid?
  end

  test "should have an 'unread' scope" do
    user = User.create(name: "Recipient User")
    notification1 = Notification.create(recipient: user, actor: User.new, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_CREATED)
    notification2 = Notification.create(recipient: user, actor: User.new, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_UPDATED, read_at: Time.current)

    unread_notifications = Notification.unread

    assert_includes unread_notifications, notification1
    assert_not_includes unread_notifications, notification2
  end

  test "should have a 'recent' scope" do
    user = User.create(name: "Recipient User")
    actor = User.create(name: "Actor User")
    notification1 = Notification.create(recipient: user, actor: actor, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_CREATED)
    notification2 = Notification.create(recipient: user, actor: actor, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_POST_UPDATED)
    notification3 = Notification.create(recipient: user, actor: actor, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_FRIEND_REQUEST)
    notification4 = Notification.create(recipient: user, actor: actor, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_REQUEST_ACCEPTED)
    notification5 = Notification.create(recipient: user, actor: actor, notifiable: Post.new, action: Notification::NOTIFICATION_TYPE_REQUEST_REJECTED)

    recent_notifications = Notification.recent

    assert_equal [notification5, notification4, notification3, notification2, notification1], recent_notifications
  end

  test "should create notifications with 'self.post' method" do
    recipient = User.create(name: "Recipient User")
    actor = User.create(name: "Actor User")
    post = Post.create(title: "Test Post")

    notifications = Notification.post(to: recipient, from: actor, action: Notification::NOTIFICATION_TYPE_POST_CREATED, notifiable: post)

    assert_equal [recipient], notifications.map(&:recipient)
    assert_equal [actor], notifications.map(&:actor)
    assert_equal [post], notifications.map(&:notifiable)
    assert_equal [Notification::NOTIFICATION_TYPE_POST_CREATED], notifications.map(&:action)
  end
end
