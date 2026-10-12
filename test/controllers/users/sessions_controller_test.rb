require 'test_helper'

Users::SessionsController.prepend(Module.new do
  def validate_turnstile(_token, _ip)
    true
  end
end)

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login never writes onboarding fields (guest choice stays guest-scoped)" do
    user = users(:one)
    user.update_columns(onboarding_choice: nil, onboarding_completed_at: nil)

    post user_session_path, params: {
      user: { email: user.email, password: 'password' },
      onboarding_choice: 'no_ai'
    }

    user.reload
    assert_nil user.onboarding_choice
    assert_nil user.onboarding_completed_at
  end

  test "login does not overwrite a choice already recorded at signup" do
    user = users(:two)
    user.update_columns(onboarding_choice: 'ai', onboarding_completed_at: 1.day.ago)
    original = user.onboarding_completed_at

    post user_session_path, params: {
      user: { email: user.email, password: 'password' },
      onboarding_choice: 'no_ai'
    }

    user.reload
    assert_equal 'ai', user.onboarding_choice
    assert_equal original.to_i, user.onboarding_completed_at.to_i
  end

  test "login without onboarding_choice leaves fields untouched" do
    user = users(:one)
    user.update_columns(onboarding_choice: nil, onboarding_completed_at: nil)

    post user_session_path, params: {
      user: { email: user.email, password: 'password' }
    }

    user.reload
    assert_nil user.onboarding_choice
    assert_nil user.onboarding_completed_at
  end
end
