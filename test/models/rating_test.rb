# test/models/rating_test.rb

require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @post = Post.create(title: 'Sample Post', user: @user)
  end

  test 'should be valid with valid attributes' do
    rating = Rating.new(user: @user, rateable: @post, value: 3)
    assert rating.valid?
  end

  test 'should not be valid without a user' do
    rating = Rating.new(rateable: @post, value: 3)
    assert_not rating.valid?
  end

  test 'should not be valid without a rateable' do
    rating = Rating.new(user: @user, value: 3)
    assert_not rating.valid?
  end

  test 'should not be valid without a value' do
    rating = Rating.new(user: @user, rateable: @post)
    assert_not rating.valid?
  end

  test 'should have a LOL_RATING constant' do
    assert_equal 6, Rating::LOL_RATING
  end

  test 'should have RATINGS constant' do
    assert_equal [0, 1, 2, 3, 4, 5, 6], Rating::RATINGS
  end

  test 'should belong to a user' do
    association = Rating.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a rateable with polymorphic association' do
    association = Rating.reflect_on_association(:rateable)
    assert_equal :belongs_to, association.macro
    assert association.options[:polymorphic]
  end

  test 'should send an email after create' do
    receiver = User.create(username: 'user2', email: 'user2@example.com', password: 'password')
    @post.users << receiver
    assert_difference('ActionMailer::Base.deliveries.count') do
      Rating.create(user: @user, rateable: @post, value: 3)
    end
  end

  test 'should not send an email to users with daily notifications turned off' do
    receiver = User.create(username: 'user3', email: 'user3@example.com', password: 'password', daily_notifications: false)
    @post.users << receiver
    assert_no_difference('ActionMailer::Base.deliveries.count') do
      Rating.create(user: @user, rateable: @post, value: 3)
    end
  end

  test 'should not send an email to users with track notifications turned off' do
    receiver = User.create(username: 'user4', email: 'user4@example.com', password: 'password', track_notifications: false)
    @post.users << receiver
    assert_no_difference('ActionMailer::Base.deliveries.count') do
      Rating.create(user: @user, rateable: @post, value: 3)
    end
  end
end
