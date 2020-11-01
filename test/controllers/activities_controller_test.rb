require 'test_helper'

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index:get" do
    get activities_index:get_url
    assert_response :success
  end

end
