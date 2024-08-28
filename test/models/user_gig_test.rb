require 'test_helper'

class UserGigTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @gig = Gig.create(title: 'Sample Gig', user: @user)
  end

  test 'should be valid with valid attributes' do
    user_gig = UserGig.new(user: @user, gig: @gig)
    assert user_gig.valid?
  end

  test 'should belong to a user' do
    association = UserGig.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to a gig' do
    association = UserGig.reflect_on_association(:gig)
    assert_equal :belongs_to, association.macro
  end
end
