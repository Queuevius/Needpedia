class Api::V1::ChatThreadsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_actor
  before_action :set_chat_thread, only: [:show, :update, :destroy]

  def index
    thread_ids = @actor.chat_threads.map(&:thread_id).uniq
    render json: { threads: thread_ids }
  end

  def show
    messages = @chat_thread.chat_messages.order(:created_at).as_json(only: [:id, :role, :content, :created_at, :metadata])
    render json: @chat_thread.as_json.merge(messages: messages)
  end

  def create
    @chat_thread = @actor.chat_threads.find_or_initialize_by(thread_id: chat_thread_params[:thread_id])
    is_new = @chat_thread.new_record?
    @chat_thread.assign_attributes(chat_thread_params.to_h.compact)

    if @chat_thread.save
      status = is_new ? :created : :ok
      render json: @chat_thread, status: status
    else
      render json: { errors: @chat_thread.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @chat_thread.update(chat_thread_params)
      render json: @chat_thread
    else
      render json: { errors: @chat_thread.errors }, status: :unprocessable_entity
    end
  end

  def current
    @current_thread = @actor.is_a?(User) ? @actor.current_chat_thread : nil
    render json: @current_thread
  end

  def set_current
    if @actor.is_a?(User)
      thread = @actor.chat_threads.find_by(thread_id: params[:thread_id])
      @actor.update(current_chat_thread: thread) if thread
    end
    render json: { success: true }
  end

  def destroy
    @chat_thread.destroy
    head :no_content
  end

  private

  def set_actor
    token = request.headers['Authorization'].to_s

    if token.present? && ENV['POST_TOKEN'].present? && token == ENV['POST_TOKEN']
      @actor = Guest.find_or_create_by!(uuid: 'vc-email-service') do |g|
        g.fingerprint = 'vc-email-service'
        g.ip = request.remote_ip
      end
      return
    end

    @actor = User.find_by(uuid: token) || Guest.find_by(uuid: token)
    return if @actor

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def set_chat_thread
    @chat_thread = @actor.chat_threads.find_by(id: params[:id]) || @actor.chat_threads.find_by(thread_id: params[:id])
    render json: { error: 'Chat thread not found' }, status: :not_found unless @chat_thread
  end

  def chat_thread_params
    params.require(:chat_thread).permit(:thread_id, :title, :last_message, :assistant_name)
  end
end
