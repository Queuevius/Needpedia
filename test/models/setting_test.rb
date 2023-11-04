require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test 'accounts_freezed should return freeze_accounts_activity from the first setting' do
    Setting.create(freeze_accounts_activity: true)
    assert Setting.accounts_freezed
  end

  test 'accounts_freezed should return nil if there is no setting' do
    assert_nil Setting.accounts_freezed
  end

  test 'posts_freezed should return freeze_posts_activity from the first setting' do
    Setting.create(freeze_posts_activity: true)
    assert Setting.posts_freezed
  end

  test 'posts_freezed should return nil if there is no setting' do
    assert_nil Setting.posts_freezed
  end

  test 'nuclear_note_active? should return true if active_nuclear_note is true and nuclear_note is not blank' do
    Setting.create(active_nuclear_note: true, nuclear_note: 'Sample note')
    assert Setting.nuclear_note_active?
  end

  test 'nuclear_note_active? should return false if active_nuclear_note is false' do
    Setting.create(active_nuclear_note: false, nuclear_note: 'Sample note')
    assert_not Setting.nuclear_note_active?
  end

  test 'nuclear_note_active? should return false if nuclear_note is blank' do
    Setting.create(active_nuclear_note: true, nuclear_note: '')
    assert_not Setting.nuclear_note_active?
  end

  test 'nuclear_note_active? should return false if there is no setting' do
    assert_not Setting.nuclear_note_active?
  end

  # Add more specific tests for the behavior of other methods if needed.
end
