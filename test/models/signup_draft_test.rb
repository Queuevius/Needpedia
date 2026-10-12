require 'test_helper'

class SignupDraftTest < ActiveSupport::TestCase
  test "create_draft! stores minimal payload with short TTL" do
    draft = SignupDraft.create_draft!(name: 'Guest', email: 'guest@example.com')
    assert draft.persisted?
    assert draft.token.present?
    assert_in_delta Time.current + SignupDraft::TTL, draft.expires_at, 5.seconds
  end

  test "find_valid returns unconsumed unexpired draft only" do
    draft = SignupDraft.create_draft!(name: 'Guest', email: 'guest@example.com')
    assert_equal draft, SignupDraft.find_valid(draft.token)

    assert_nil SignupDraft.find_valid('')
    assert_nil SignupDraft.find_valid(nil)
    assert_nil SignupDraft.find_valid('bogus-token')

    draft.update_columns(expires_at: 1.minute.ago)
    assert_nil SignupDraft.find_valid(draft.token)

    draft.update_columns(expires_at: 10.minutes.from_now, consumed_at: Time.current)
    assert_nil SignupDraft.find_valid(draft.token)
  end

  test "consume! is one-time and idempotent" do
    draft = SignupDraft.create_draft!(name: 'Guest', email: 'guest@example.com')
    draft.consume!
    first_consumed = draft.reload.consumed_at
    draft.consume!
    assert_equal first_consumed, draft.reload.consumed_at
  end

  test "invalid email raises" do
    assert_raises(ActiveRecord::RecordInvalid) do
      SignupDraft.create_draft!(name: 'Guest', email: 'nope')
    end
  end

  test "create_draft! purges drafts expired for over a day" do
    old = SignupDraft.create_draft!(name: 'Old', email: 'old@example.com')
    old.update_columns(expires_at: 2.days.ago, created_at: 2.days.ago)

    SignupDraft.create_draft!(name: 'New', email: 'new@example.com')
    assert_nil SignupDraft.find_by(id: old.id)
  end
end
