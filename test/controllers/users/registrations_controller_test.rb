require 'test_helper'

# Turnstile must never hit Cloudflare from the test suite.
Users::RegistrationsController.prepend(Module.new do
  def validate_turnstile(_token, _ip)
    true
  end
end)

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signup with onboarding_choice persists choice and completion timestamp" do
    assert_difference 'User.count', 1 do
      post user_registration_path, params: {
        user: { name: 'Ob One', email: 'onboard_ctrl@example.com', password: 'Password1!', password_confirmation: 'Password1!' },
        onboarding_choice: 'ai'
      }
    end

    user = User.find_by(email: 'onboard_ctrl@example.com')
    assert_equal 'ai', user.onboarding_choice
    assert user.onboarding_completed_at.present?
  end

  test "signup without a whitelisted choice leaves onboarding fields nil" do
    assert_difference 'User.count', 1 do
      post user_registration_path, params: {
        user: { email: 'onboard_ctrl2@example.com', password: 'Password1!', password_confirmation: 'Password1!' },
        onboarding_choice: 'banana'
      }
    end

    user = User.find_by(email: 'onboard_ctrl2@example.com')
    assert_nil user.onboarding_choice
    assert_nil user.onboarding_completed_at
  end

  test "signup form prefills name and email from a valid Florence draft" do
    draft = SignupDraft.create_draft!(name: 'Draft Person', email: 'draft_person@example.com')

    get new_user_registration_path, params: { draft: draft.token }
    assert_response :success
    assert_select 'input[name="user[name]"][value="Draft Person"]'
    assert_select 'input[name="user[email]"][value="draft_person@example.com"]'
    assert_select 'input[name="draft"][value=?]', draft.token
  end

  test "signup form stays plain for an unknown or expired draft" do
    get new_user_registration_path, params: { draft: 'bogus' }
    assert_response :success
    assert_select 'input[name="draft"]', count: 0
    assert_select 'input[name="user[name]"][value="Draft Person"]', count: 0
  end

  test "successful signup consumes the Florence draft" do
    draft = SignupDraft.create_draft!(name: 'Draft Two', email: 'draft_two@example.com')

    assert_difference 'User.count', 1 do
      post user_registration_path, params: {
        user: { name: 'Draft Two', email: 'draft_two@example.com', password: 'Password1!', password_confirmation: 'Password1!' },
        draft: draft.token
      }
    end
    assert draft.reload.consumed_at.present?
  end

  test "failed signup leaves the draft unconsumed for retry" do
    draft = SignupDraft.create_draft!(name: 'Draft Three', email: 'draft_three@example.com')

    assert_no_difference 'User.count' do
      post user_registration_path, params: {
        user: { name: 'Draft Three', email: 'draft_three@example.com', password: 'Password1!', password_confirmation: 'Mismatch!' },
        draft: draft.token
      }
    end
    assert_nil draft.reload.consumed_at
  end
end
