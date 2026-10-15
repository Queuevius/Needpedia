class Api::V1::TasksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_actor
  before_action :check_rate_limit, only: [:create]

  RATE_LIMIT = 5
  RATE_WINDOW = 10.minutes

  # Bridge for the Lotte assistant (and other token-authenticated callers).
  # Creates group-scoped tasks ONLY: the caller must own the group or hold a
  # membership in it. Status is forced to 'Available Tasks' so a token caller
  # cannot mint pre-completed tasks and trigger the impact-reward callback.
  def create
    group = Group.find_by(id: params[:group_id])
    return render json: { error: 'Group not found' }, status: :not_found unless group

    unless group.user_id == @actor.id || group.memberships.exists?(user_id: @actor.id)
      return render json: { error: 'Not a member of this group' }, status: :forbidden
    end

    task = group.tasks.build(task_params.merge(user: @actor, status: 'Available Tasks'))
    if task.save
      render json: { id: task.id, title: task.title, status: task.status }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Groups the caller can target from a task-draft confirm card:
  # owned groups plus memberships.
  def groups
    owned = Group.where(user_id: @actor.id)
    member_of = Group.where(id: Membership.where(user_id: @actor.id).select(:group_id))
    render json: owned.or(member_of).order(:id).select(:id, :name)
  end

  private

  def task_params
    params.permit(:title, :description, :hours)
  end

  def set_actor
    token = request.headers['token'].to_s
    @actor = User.find_by(uuid: token)
    return if @actor

    if auth_failures_over_limit?
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Same abuse guards as the signup bridge: sliding-window per IP,
  # successes and failed-auth guesses capped separately.
  def check_rate_limit
    return if performed?

    ip = request.remote_ip
    now = Time.current
    self.class.rate_mutex.synchronize do
      hits = self.class.rate_store[ip]
      hits.reject! { |t| t < now - RATE_WINDOW }
      if hits.size >= RATE_LIMIT
        render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
        return
      end
      hits << now
    end
  end

  def auth_failures_over_limit?
    ip = request.remote_ip
    now = Time.current
    self.class.rate_mutex.synchronize do
      fails = self.class.auth_fail_store[ip]
      fails.reject! { |t| t < now - RATE_WINDOW }
      fails << now
      fails.size > RATE_LIMIT
    end
  end

  class << self
    def rate_store
      @rate_store ||= Hash.new { |h, k| h[k] = [] }
    end

    def auth_fail_store
      @auth_fail_store ||= Hash.new { |h, k| h[k] = [] }
    end

    def rate_mutex
      @rate_mutex ||= Mutex.new
    end

    def reset_rate_store!
      rate_mutex.synchronize do
        rate_store.clear
        auth_fail_store.clear
      end
    end
  end
end
