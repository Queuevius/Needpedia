# test/models/user_test.rb

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "Password@123",
      password_confirmation: "Password@123"
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should require an email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require a password" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "should have many notifications" do
    assert_association(@user, :notifications)
  end

  test "should have many services" do
    assert_association(@user, :services, dependent: :destroy)
  end

  test "credit hours calculation is correct" do
    assert_equal 0, @user.credit_hours  # Test the initial state
  end

  test "add_default_credit should create a transaction" do
    @user.add_default_credit
    assert_equal 1, @user.transactions.count
  end

  test "create_admin_notifications should create notifications" do
    @user.create_admin_notifications
    assert_equal expected_notification_count, @user.notifications.count
  end

  test "make_friend_with_mascot should create a connection" do
    @user.make_friend_with_mascot
    assert_equal 1, @user.connections.count
  end

  test "links should return user connections" do
    assert_equal expected_connection_count, @user.links.count
  end

  test "is_connected_with should return true for connected users" do
    assert @user.is_connected_with(connected_user)
  end

  test "delete_notifications should remove notifications" do
    @user.delete_notifications
    assert_equal 0, @user.notifications.count
  end

  test "create_user_tutorials should create user tutorials" do
    @user.create_user_tutorials
    assert_equal expected_tutorial_count, @user.user_tutorials.count
  end
end
