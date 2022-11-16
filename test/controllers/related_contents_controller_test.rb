require 'test_helper'

class RelatedContentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @related_content = related_contents(:one)
  end

  test "should get index" do
    get related_contents_url
    assert_response :success
  end

  test "should get new" do
    get new_related_content_url
    assert_response :success
  end

  test "should create related_content" do
    assert_difference('RelatedContent.count') do
      post related_contents_url, params: { related_content: {  } }
    end

    assert_redirected_to related_content_url(RelatedContent.last)
  end

  test "should show related_content" do
    get related_content_url(@related_content)
    assert_response :success
  end

  test "should get edit" do
    get edit_related_content_url(@related_content)
    assert_response :success
  end

  test "should update related_content" do
    patch related_content_url(@related_content), params: { related_content: {  } }
    assert_redirected_to related_content_url(@related_content)
  end

  test "should destroy related_content" do
    assert_difference('RelatedContent.count', -1) do
      delete related_content_url(@related_content)
    end

    assert_redirected_to related_contents_url
  end
end
