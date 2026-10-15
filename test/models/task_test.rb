require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @assignee = users(:two)
    @group = Group.create!(name: 'Task Test Group', user: @owner)
  end

  def build_task(attrs = {})
    Task.new({ group: @group, user: @owner, title: 'Wash dishes',
               description: 'Sink is full', hours: 2 }.merge(attrs))
  end

  test 'status column default is a valid status, not a priority' do
    assert_equal 'Available Tasks', Task.new.status
    task = build_task
    assert task.valid?, task.errors.full_messages.join(', ')
  end

  test 'Casual status is rejected by validation' do
    task = build_task(status: 'Casual')
    refute task.valid?
    assert_includes task.errors[:status], 'is not included in the list'
  end

  test 'completing with assignee creates exactly one impact reward' do
    task = build_task(assignee: @assignee)
    task.save!

    assert_difference 'Impact.count', 1 do
      task.update!(status: 'Completed Tasks')
    end

    impact = Impact.last
    assert_equal @assignee, impact.user
    assert_equal 'Task Completed', impact.badge
    assert_equal 'Completed: Wash dishes', impact.description
  end

  test 're-saving a completed task does not duplicate the impact' do
    task = build_task(assignee: @assignee)
    task.save!
    task.update!(status: 'Completed Tasks')

    assert_no_difference 'Impact.count' do
      task.update!(description: 'edited after completion')
      task.update!(title: 'Wash dishes (urgent)')
      task.reload
      task.update!(status: 'Completed Tasks') # idempotent even if re-asserted
    end
  end

  test 'reopen then complete again keeps a single impact' do
    task = build_task(assignee: @assignee)
    task.save!
    task.update!(status: 'Completed Tasks')
    task.update!(status: 'Under Progress')

    assert_no_difference 'Impact.count' do
      task.update!(status: 'Completed Tasks')
    end
    assert_equal 1, Impact.where(user_id: @assignee.id, description: 'Completed: Wash dishes').count
  end

  test 'completing without assignee creates no impact' do
    task = build_task
    task.save!

    assert_no_difference 'Impact.count' do
      task.update!(status: 'Completed Tasks')
    end
  end

  test 'rename after completion does not mint a second impact on recomplete' do
    task = build_task(assignee: @assignee)
    task.save!
    task.update!(status: 'Completed Tasks')
    task.update!(title: 'Wash dishes (urgent)')
    task.update!(status: 'Under Progress')

    assert_no_difference 'Impact.count' do
      task.update!(status: 'Completed Tasks')
    end
    assert_equal 1, Impact.where(user_id: @assignee.id, task_id: task.id).count
  end

  test 'two tasks with the same title each award their own impact' do
    first = build_task(assignee: @assignee)
    first.save!
    second = build_task(assignee: @assignee)
    second.save!

    assert_difference 'Impact.count', 2 do
      first.update!(status: 'Completed Tasks')
      second.update!(status: 'Completed Tasks')
    end
    assert_equal 1, Impact.where(user_id: @assignee.id, task_id: first.id).count
    assert_equal 1, Impact.where(user_id: @assignee.id, task_id: second.id).count
  end

  test 'blank title is rejected' do
    task = build_task(title: '')
    refute task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test 'non-completion transitions create no impact' do
    task = build_task(assignee: @assignee)
    task.save!

    assert_no_difference 'Impact.count' do
      task.update!(status: 'Under Progress')
    end
  end
end
