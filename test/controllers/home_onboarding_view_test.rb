require 'test_helper'

class HomeOnboardingViewTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guest sees the onboarding overlay" do
    get root_path
    assert_response :success
    assert_select '#np-onboarding[data-authed=?]', '0', count: 1
  end

  test "authed user with pending onboarding sees the overlay" do
    user = users(:one)
    user.update_columns(onboarding_choice: nil, onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_response :success
    assert_select '#np-onboarding[data-authed=?]', '1', count: 1
    assert_select '#np-resources', count: 1
  end

  test "authed user with completed onboarding does not see the overlay" do
    user = users(:two)
    user.update_columns(onboarding_choice: 'ai', onboarding_completed_at: Time.current)
    sign_in user

    get root_path
    assert_response :success
    assert_select '#np-onboarding', count: 0
  end
end
