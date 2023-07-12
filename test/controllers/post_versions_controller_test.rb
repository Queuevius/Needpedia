require 'test_helper'

class PostVersionsControllerTest < ActionDispatch::IntegrationTest
  test "should get restore" do
    get post_versions_restore_url
    assert_response :success
  end

  test "should get report" do
    get post_versions_report_url
    assert_response :success
  end

  test "should get request_delete" do
    get post_versions_request_delete_url
    assert_response :success
  end

end
