require 'test_helper'

class SignupDraftApiTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV['SIGNUP_BRIDGE_TOKEN']
    ENV['SIGNUP_BRIDGE_TOKEN'] = 'bridge-secret'
  end

  teardown do
    ENV['SIGNUP_BRIDGE_TOKEN'] = @previous_token
    Api::V1::SignupDraftsController.reset_rate_store!
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

  test "abuse guard: returns 429 after RATE_LIMIT drafts in window" do
    Api::V1::SignupDraftsController::RATE_LIMIT.times do |i|
      post '/api/v1/signup_draft', params: {
        signup_draft: { name: "Spammer #{i}", email: "spam#{i}@example.com" },
        bridge_token: 'bridge-secret'
      }
      assert_response :created, "draft #{i + 1} should still succeed"
    end

    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'Spammer over', email: 'over@example.com' },
      bridge_token: 'bridge-secret'
    }
    assert_response :too_many_requests
    assert_equal 'Rate limit exceeded', JSON.parse(response.body)['error']
  end

  test "abuse guard: does not leak tokens or drafts on 429" do
    (Api::V1::SignupDraftsController::RATE_LIMIT + 1).times do |i|
      post '/api/v1/signup_draft', params: {
        signup_draft: { name: "N #{i}", email: "n#{i}@example.com" },
        bridge_token: 'bridge-secret'
      }
    end
    assert_response :too_many_requests
    body = JSON.parse(response.body)
    assert_nil body['draft_token']
    refute body.key?('errors')
  end

  test "abuse guard: only counts successful-auth requests, not rejected tokens" do
    # Burn the success-budget cap with bad tokens — these must NOT consume it.
    # Stay at exactly RATE_LIMIT so they remain 401 (the separate failed-auth
    # cap also lives at RATE_LIMIT; going over would flip them to 429).
    Api::V1::SignupDraftsController::RATE_LIMIT.times do
      post '/api/v1/signup_draft', params: {
        signup_draft: { name: 'X', email: 'x@example.com' },
        bridge_token: 'wrong-token'
      }
      assert_response :unauthorized
    end

    # Real caller still has full success budget.
    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'Real', email: 'real@example.com' },
      bridge_token: 'bridge-secret'
    }
    assert_response :created
  end

  test "abuse guard: caps failed-auth brute force after RATE_LIMIT attempts" do
    Api::V1::SignupDraftsController::RATE_LIMIT.times do
      post '/api/v1/signup_draft', params: {
        signup_draft: { name: 'X', email: 'x@example.com' },
        bridge_token: 'wrong-token'
      }
      assert_response :unauthorized
    end

    # 6th bad token is blocked outright — no more guessing.
    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'X', email: 'x@example.com' },
      bridge_token: 'another-wrong-token'
    }
    assert_response :too_many_requests
    assert_equal 'Rate limit exceeded', JSON.parse(response.body)['error']

    # A correct token still works: the brute-force cap must not DoS the
    # legitimate caller sharing the same IP.
    post '/api/v1/signup_draft', params: {
      signup_draft: { name: 'Real', email: 'real@example.com' },
      bridge_token: 'bridge-secret'
    }
    assert_response :created
  end
end
