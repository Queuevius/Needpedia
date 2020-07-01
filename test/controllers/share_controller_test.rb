require 'test_helper'

class ShareControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get share_create_url
    assert_response :success
  end

end
