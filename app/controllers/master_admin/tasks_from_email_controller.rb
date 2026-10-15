module MasterAdmin
  # Paste-an-email intake: master admin pastes a forwarded email (subject +
  # body) and it becomes an Available task in a chosen group. This is NOT
  # inbound email — no mail is fetched or web-hooked; scope label matters at
  # client acceptance.
  class TasksFromEmailController < MasterAdmin::ApplicationController
    def new
      @task = Task.new
      load_form_data
    end

    def create
      group = Group.find_by(id: params[:group_id])
      if group.nil?
        load_form_data(task_from_params)
        flash.now[:alert] = 'Choose a group.'
        return render :new, status: :unprocessable_entity
      end

      assignee = params[:assignee_email].to_s.strip.presence &&
                 User.find_by(email: params[:assignee_email].to_s.strip.downcase)
      if params[:assignee_email].present? && assignee.nil?
        load_form_data(task_from_params)
        flash.now[:alert] = 'No user found with that assignee email.'
        return render :new, status: :unprocessable_entity
      end

      task = group.tasks.build(
        user: current_user,
        title: params[:subject].to_s.strip,
        description: params[:body].to_s.strip,
        hours: params[:hours].presence || 1.0,
        status: 'Available Tasks',
        assignee: assignee
      )

      if task.save
        redirect_to group_path(group), notice: 'Task created from pasted email (manual intake, not inbound email).'
      else
        load_form_data(task)
        flash.now[:alert] = task.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def task_from_params
      Task.new(
        title: params[:subject],
        description: params[:body],
        hours: params[:hours],
        group_id: params[:group_id]
      )
    end

    def load_form_data(task = nil)
      @task = task || Task.new
      @groups = Group.order(:name)
    end
  end
end
