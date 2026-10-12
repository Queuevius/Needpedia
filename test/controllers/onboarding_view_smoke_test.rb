require 'test_helper'

class OnboardingViewSmokeTest < ActionDispatch::IntegrationTest
  test "signup form renders onboarding partial; login form does not" do
    get new_user_registration_path
    assert_response :success
    assert_select 'input#onboarding_choice', 1

    get new_user_session_path
    assert_response :success
    assert_select 'input#onboarding_choice', 0
  end
end
