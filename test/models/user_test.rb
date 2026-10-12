require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "onboarding fields persist and onboarding_completed? reflects completion" do
    user = User.create!(email: 'onboard1@example.com', password: 'Password1!', password_confirmation: 'Password1!')
    assert_nil user.onboarding_choice
    refute user.onboarding_completed?

    user.update_columns(onboarding_choice: 'ai', onboarding_completed_at: Time.current)
    user.reload
    assert_equal 'ai', user.onboarding_choice
    assert user.onboarding_completed?
  end

  test "choice without timestamp is not completed" do
    user = User.create!(email: 'onboard2@example.com', password: 'Password1!', password_confirmation: 'Password1!')
    user.update_column(:onboarding_choice, 'no_ai')
    user.reload
    assert_equal 'no_ai', user.onboarding_choice
    refute user.onboarding_completed?
  end
end
