class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]
  # GET /tasks/1 or /tasks/1.json
  def show
    @comments = @task.comments.includes(:user, :replies).order(created_at: :asc)
    @new_comment = Comment.new # For the new comment form
  end

  # GET /tasks/new
  def new
    @group = Group.find(params[:group])
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit; end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to group_path(@task.group), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    current_task_params = task_params.to_h
    if current_task_params.key?(:assignee_id) && current_task_params[:assignee_id].blank?
      current_task_params[:assignee_id] = nil
    end

    respond_to do |format|
      if @task.update(current_task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render json: { status: :ok, message: 'Task was successfully updated.', assignee_name: @task.assignee&.name } }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.html do
        redirect_to group_path(@task.group), status: :see_other, notice: 'Task was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Task not found.'
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :description, :city, :user_id, :group_id, :skills, :hours, :status, :priority, :assignee_id, :check_back_date, images: [])
  end
end
