require 'test_helper'

class ObjectivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @objective = objectives(:one)
  end

  test "should get index" do
    get objectives_url
    assert_response :success
  end

  test "should get new" do
    get new_objective_url
    assert_response :success
  end

  test "should create objective" do
    assert_difference('Objective.count') do
      post objectives_url, params: { objective: {  } }
    end

    assert_redirected_to objective_url(Objective.last)
  end

  test "should show objective" do
    get objective_url(@objective)
    assert_response :success
  end

  test "should get edit" do
    get edit_objective_url(@objective)
    assert_response :success
  end

  test "should update objective" do
    patch objective_url(@objective), params: { objective: {  } }
    assert_redirected_to objective_url(@objective)
  end

  test "should destroy objective" do
    assert_difference('Objective.count', -1) do
      delete objective_url(@objective)
    end

    assert_redirected_to objectives_url
  end
end
