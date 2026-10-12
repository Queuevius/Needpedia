require 'test_helper'

class SignupDraftApiTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV['SIGNUP_BRIDGE_TOKEN']
    ENV['SIGNUP_BRIDGE_TOKEN'] = 'bridge-secret'
  end

  teardown do
    ENV['SIGNUP_BRIDGE_TOKEN'] = @previous_token
  end

  test "rejects request without bridge token" do
    post '/api/v1/signup_draft', params: { signup_draft: { name: 'A', email: 'a@b.com' } }
    assert_response :unauthorized
  end

  test "rejects request with wrong bridge token" do
    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'A', email: 'a@b.com' },
      bridge_token: 'nope'
    }
    assert_response :unauthorized
  end

  test "creates draft and returns token" do
    assert_difference 'SignupDraft.count', 1 do
      post '/api/v1/signup_draft', params: {
        signup_draft: { name: 'Florence Guest', email: 'guest@example.com' },
        bridge_token: 'bridge-secret'
      }
    end
    assert_response :created
    token = JSON.parse(response.body)['draft_token']
    assert token.present?
    draft = SignupDraft.find_by(token: token)
    assert_equal 'Florence Guest', draft.name
    assert_equal 'guest@example.com', draft.email
    assert_nil draft.consumed_at
    assert draft.expires_at > Time.current
  end

  test "rejects invalid email" do
    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'A', email: 'not-an-email' },
      bridge_token: 'bridge-secret'
    }
    assert_response :unprocessable_entity
    assert_match(/Email/, JSON.parse(response.body)['errors'].join)
  end
end
