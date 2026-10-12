require 'test_helper'

class FlorenceOnboardingPathTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guest homepage passes firsttime to Florence and does not auto-open the window" do
    get root_path
    assert_response :success
    assert_select '#navbarDropdown'
    frame = css_select('.chat-dropdown iframe').first
    assert frame, 'expected butler iframe'
    assert_match(/sidebar=false&firsttime=true/, frame['src'])
    assert_no_match(/dropdown\(['"]show['"]\)/, response.body)
  end

  test "authed user without chat threads gets firsttime on homepage" do
    user = users(:one)
    user.chat_threads.destroy_all
    sign_in user

    get root_path
    assert_response :success
    assert_select '#navbarDropdown'
    frame = css_select('.chat-dropdown iframe').first
    assert frame, 'expected butler iframe'
    assert_match(/sidebar=false&firsttime=true/, frame['src'])
    assert_no_match(/dropdown\(['"]show['"]\)/, response.body)
  end

  test "authed user with chat threads does not get firsttime on homepage" do
    user = users(:one)
    user.chat_threads.destroy_all
    user.chat_threads.create!(thread_id: 'existing-thread')
    sign_in user

    get root_path
    assert_response :success
    frame = css_select('.chat-dropdown iframe').first
    assert frame, 'expected butler iframe'
    assert_no_match(/firsttime=true/, frame['src'])
    assert_match(/sidebar=false/, frame['src'])
  end

  test "guest /ai page passes firsttime to Florence" do
    get ai_path
    assert_response :success
    frame = css_select('.chatbot-frame').first
    assert frame, 'expected chatbot frame'
    assert_match(/user_token=[^&]+&firsttime=true/, frame['src'])
  end

  test "authed /ai page passes firsttime only without chat threads" do
    user = users(:one)
    user.chat_threads.destroy_all
    sign_in user

    get ai_path
    assert_response :success
    frame = css_select('.chatbot-frame').first
    assert frame, 'expected chatbot frame'
    assert_match(/user_token=[^&]+&firsttime=true/, frame['src'])

    user.chat_threads.create!(thread_id: 'existing-thread-2')
    get ai_path
    assert_no_match(/firsttime=true/, css_select('.chatbot-frame').first['src'])
  end
end
