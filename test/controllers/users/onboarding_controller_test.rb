require 'test_helper'

class Users::OnboardingControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "unauthenticated request is unauthorized" do
    patch user_onboarding_path, params: { onboarding_choice: 'ai' }
    assert_response :unauthorized
  end

  test "valid choice records choice and completion" do
    user = users(:one)
    sign_in user

    patch user_onboarding_path, params: { onboarding_choice: 'no_ai' }
    assert_response :no_content

    user.reload
    assert_equal 'no_ai', user.onboarding_choice
    assert user.onboarding_completed_at.present?
  end

  test "non-whitelisted choice is rejected" do
    user = users(:one)
    sign_in user

    patch user_onboarding_path, params: { onboarding_choice: 'banana' }
    assert_response :unprocessable_entity

    user.reload
    assert_nil user.onboarding_choice
    assert_nil user.onboarding_completed_at
  end

  test "already completed user is not overwritten" do
    user = users(:two)
    user.update_columns(onboarding_choice: 'ai', onboarding_completed_at: 1.day.ago)
    original = user.onboarding_completed_at
    sign_in user

    patch user_onboarding_path, params: { onboarding_choice: 'no_ai' }
    assert_response :no_content

    user.reload
    assert_equal 'ai', user.onboarding_choice
    assert_equal original.to_i, user.onboarding_completed_at.to_i
  end
end
