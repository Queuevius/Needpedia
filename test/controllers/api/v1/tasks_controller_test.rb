require 'test_helper'

class Api::V1::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @member = users(:two)
    @outsider = User.create!(email: 'outsider@example.com',
                             password: 'Password1!',
                             password_confirmation: 'Password1!',
                             confirmed_at: Time.current)
    @outsider.reload # uuid is a DB-side default; refresh it onto the Ruby object
    @group = Group.create!(name: 'Council Group', user: @owner)
    @group.members << @member
    @other_group = Group.create!(name: 'Other Group', user: @outsider)
    Api::V1::TasksController.reset_rate_store!
  end

  teardown do
    Api::V1::TasksController.reset_rate_store!
  end

  def token_for(user)
    { 'token' => user.uuid }
  end

  def valid_task_params(group)
    { group_id: group.id, title: 'Drafted task', description: 'From Lotte', hours: 2 }
  end

  test 'rejects request without token' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks', params: valid_task_params(@group)
    end
    assert_response :unauthorized
  end

  test 'rejects request with wrong token' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: { 'token' => 'not-a-uuid' }
    end
    assert_response :unauthorized
  end

  test 'rejects guest uuid: tasks require a real user' do
    guest = Guest.create!(uuid: 'guest-uuid-1', fingerprint: 'fp', ip: '1.2.3.4')
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: { 'token' => guest.uuid }
    end
    assert_response :unauthorized
  end

  test 'group member can create a task' do
    assert_difference 'Task.count', 1 do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: token_for(@member)
    end
    assert_response :created
    task = Task.last
    assert_equal @group, task.group
    assert_equal @member, task.user
    assert_equal 'Drafted task', task.title
    assert_equal 'Available Tasks', task.status
    assert_equal 2, task.hours.to_i
  end

  test 'group owner can create a task' do
    assert_difference 'Task.count', 1 do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: token_for(@owner)
    end
    assert_response :created
  end

  test 'cross-group create is rejected: non-member cannot inject task into foreign group' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: token_for(@outsider)
    end
    assert_response :forbidden
    assert_equal 'Not a member of this group', JSON.parse(response.body)['error']
  end

  test 'nonexistent group returns 404' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks',
           params: { group_id: 0, title: 'T', description: 'D', hours: 1 },
           headers: token_for(@member)
    end
    assert_response :not_found
  end

  test 'invalid task returns 422 with errors' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks',
           params: { group_id: @group.id, title: '', description: '', hours: -3 },
           headers: token_for(@member)
    end
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body['errors'].present?
  end

  test 'blank title is rejected even with valid hours' do
    assert_no_difference 'Task.count' do
      post '/api/v1/tasks',
           params: { group_id: @group.id, title: '   ', description: 'body', hours: 1 },
           headers: token_for(@member)
    end
    assert_response :unprocessable_entity
    assert_match(/title/i, response.body)
  end

  test 'rate limit caps successful creates per window' do
    (Api::V1::TasksController::RATE_LIMIT).times do |i|
      post '/api/v1/tasks',
           params: valid_task_params(@group).merge(title: "T#{i}"),
           headers: token_for(@member)
      assert_response :created, "create #{i + 1} should succeed"
    end

    post '/api/v1/tasks', params: valid_task_params(@group), headers: token_for(@member)
    assert_response :too_many_requests
    assert_equal 'Rate limit exceeded', JSON.parse(response.body)['error']
  end

  test 'brute-force cap: repeated bad tokens flip to 429' do
    Api::V1::TasksController::RATE_LIMIT.times do
      post '/api/v1/tasks', params: valid_task_params(@group), headers: { 'token' => 'bad-token' }
      assert_response :unauthorized
    end

    post '/api/v1/tasks', params: valid_task_params(@group), headers: { 'token' => 'still-bad' }
    assert_response :too_many_requests
  end

  test 'groups index returns only groups the caller owns or belongs to' do
    get '/api/v1/tasks/groups', headers: token_for(@member)
    assert_response :success
    ids = JSON.parse(response.body).map { |g| g['id'] }
    assert_includes ids, @group.id
    refute_includes ids, @other_group.id
  end

  test 'groups index rejects missing token' do
    get '/api/v1/tasks/groups'
    assert_response :unauthorized
  end
end
