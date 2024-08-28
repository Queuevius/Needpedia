require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
  end

  test 'should be valid with valid attributes' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert service.valid?
  end

  test 'should not be valid without a user' do
    service = Service.new(provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_not service.valid?
  end

  test 'should not be valid without a provider' do
    service = Service.new(user: @user, access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_not service.valid?
  end

  test 'should have a client method' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_respond_to service, :client
  end

  test 'should have an expired? method' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_respond_to service, :expired?
  end

  test 'should have an access_token method' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_respond_to service, :access_token
  end

  test 'should have a twitter_client method' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_respond_to service, :twitter_client
  end

  test 'should have a twitter_refresh_token! method' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_respond_to service, :twitter_refresh_token!
  end

  test 'expired? should return true if expires_at is in the past' do
    expired_service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current - 1.hour)
    assert expired_service.expired?
  end

  test 'expired? should return false if expires_at is in the future' do
    valid_service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    assert_not valid_service.expired?
  end

  test 'access_token should call twitter_refresh_token! if expired' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current - 1.hour)

    assert service.expired?
    assert service.expects(:twitter_refresh_token!).returns('new_access_token')
    assert_equal 'new_access_token', service.access_token
  end

  test 'access_token should return the stored access_token if not expired' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)

    assert_not service.expired?
    assert_not service.expects(:twitter_refresh_token!).never
    assert_equal 'access_token', service.access_token
  end

  test 'twitter_client should create a Twitter::REST::Client' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current + 1.hour)
    client = service.twitter_client

    assert_instance_of Twitter::REST::Client, client
  end

  test 'twitter_refresh_token! should be implemented' do
    service = Service.new(user: @user, provider: 'twitter', access_token: 'access_token', access_token_secret: 'access_token_secret', expires_at: Time.current - 1.hour)
    assert_respond_to service, :twitter_refresh_token!
  end

end
