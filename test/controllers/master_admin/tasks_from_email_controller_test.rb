require 'test_helper'

class MasterAdmin::TasksFromEmailControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:one)
    @admin.update_columns(master_admin: true)
    @group = Group.create!(name: 'Paste Test Group', user: @admin)
    @assignee = users(:two)
  end

  test 'guest cannot open the paste form' do
    get master_admin_task_from_email_path
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test 'signed-in non master admin cannot open the paste form' do
    sign_in users(:two)
    get master_admin_task_from_email_path
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test 'signed-in non master admin cannot create a task' do
    sign_in users(:two)
    assert_no_difference 'Task.count' do
      post master_admin_create_task_from_email_path, params: {
        group_id: @group.id, subject: 'hack', body: 'nope'
      }
    end
    assert_redirected_to root_path
    assert_equal 'Not authorized.', flash[:alert]
  end

  test 'master admin opens the paste form with group selector' do
    sign_in @admin
    get master_admin_task_from_email_path
    assert_response :success
    assert_select 'select[name="group_id"]'
    assert_select 'input[name="subject"]'
    assert_select 'textarea[name="body"]'
    assert_select 'input[name="assignee_email"]'
  end

  test 'master admin paste creates an Available task in the chosen group' do
    sign_in @admin
    assert_difference 'Task.count', 1 do
      post master_admin_create_task_from_email_path, params: {
        group_id: @group.id,
        subject: 'Fix the fence',
        body: 'Forwarded email body about the fence.',
        hours: '3.5',
        assignee_email: @assignee.email
      }
    end

    task = Task.last
    assert_equal 'Fix the fence', task.title
    assert_equal 'Forwarded email body about the fence.', task.description
    assert_equal 'Available Tasks', task.status
    assert_equal 3.5, task.hours
    assert_equal @group, task.group
    assert_equal @admin, task.user
    assert_equal @assignee, task.assignee
    assert_redirected_to group_path(@group)
  end

  test 'paste without assignee email creates an unassigned task' do
    sign_in @admin
    assert_difference 'Task.count', 1 do
      post master_admin_create_task_from_email_path, params: {
        group_id: @group.id, subject: 'Unassigned job', body: 'body'
      }
    end
    assert_nil Task.last.assignee
    assert_equal 'Available Tasks', Task.last.status
  end

  test 'missing group renders form again with alert, creates nothing' do
    sign_in @admin
    assert_no_difference 'Task.count' do
      post master_admin_create_task_from_email_path, params: {
        subject: 'Orphan', body: 'no group'
      }
    end
    assert_response :unprocessable_entity
    assert_match(/group/i, flash[:alert])
  end

  test 'unknown assignee email is rejected, creates nothing' do
    sign_in @admin
    assert_no_difference 'Task.count' do
      post master_admin_create_task_from_email_path, params: {
        group_id: @group.id,
        subject: 'Ghost assign',
        body: 'body',
        assignee_email: 'nobody@example.com'
      }
    end
    assert_response :unprocessable_entity
    assert_match(/No user found/i, flash[:alert])
  end

  test 'error paths preserve pasted subject, body and group selection' do
    sign_in @admin
    post master_admin_create_task_from_email_path, params: {
      group_id: @group.id,
      subject: 'Keep me',
      body: 'Keep this body too',
      hours: '2',
      assignee_email: 'nobody@example.com'
    }
    assert_response :unprocessable_entity
    assert_select 'input[name="subject"][value="Keep me"]'
    assert_select 'textarea[name="body"]', text: 'Keep this body too'
    assert_select "select[name='group_id'] option[selected='selected'][value='#{@group.id}']"
  end
end
