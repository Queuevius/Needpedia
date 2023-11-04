require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user)
  end

  test 'should be valid with valid attributes' do
    share = Share.new(shareable: @post, user: @user)
    assert share.valid?
  end

  test 'should not be valid without a shareable' do
    share = Share.new(user: @user)
    assert_not share.valid?
  end

  test 'should not be valid without a user' do
    share = Share.new(shareable: @post)
    assert_not share.valid?
  end

  test 'should belong to a shareable with polymorphic association' do
    association = Share.reflect_on_association(:shareable)
    assert_equal :belongs_to, association.macro
    assert association.options[:polymorphic]
  end

  test 'should belong to a user' do
    association = Share.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'send_email should send tracking emails to users with daily_notifications and track_notifications enabled' do
    receiver = User.create(username: 'user2', email: 'user2@example.com', password: 'password', daily_notifications: true, track_notifications: true)
    @post.users << receiver

    assert_difference('ActionMailer::Base.deliveries.count') do
      Share.create(shareable: @post, user: @user)
    end
  end

  test 'send_email should not send tracking emails to users with daily_notifications turned off' do
    receiver = User.create(username: 'user3', email: 'user3@example.com', password: 'password', daily_notifications: false, track_notifications: true)
    @post.users << receiver

    assert_no_difference('ActionMailer::Base.deliveries.count') do
      Share.create(shareable: @post, user: @user)
    end
  end

  test 'send_email should not send tracking emails to users with track_notifications turned off' do
    receiver = User.create(username: 'user4', email: 'user4@example.com', password: 'password', daily_notifications: true, track_notifications: false)
    @post.users << receiver

    assert_no_difference('ActionMailer::Base.deliveries.count') do
      Share.create(shareable: @post, user: @user)
    end
  end

  test 'send_email should not send tracking emails to users with both notifications turned off' do
    receiver = User.create(username: 'user5', email: 'user5@example.com', password: 'password', daily_notifications: false, track_notifications: false)
    @post.users << receiver

    assert_no_difference('ActionMailer::Base.deliveries.count') do
      Share.create(shareable: @post, user: @user)
    end
  end
end
