class Api::V1::ChatThreadsController < ApplicationController
  before_action :set_chat_thread, only: [:show, :update, :destroy]

  def index
    user = User.find_by(uuid: request.headers['Authorization']) || Guest.find_by(uuid: request.headers['Authorization'])
    thread_ids = user.chat_threads.map(&:thread_id).uniq

    render json: { threads: thread_ids }
  end

  def show
    render json: @chat_thread
  end

  def create
    user = User.find_by(uuid: request.headers['Authorization']) || Guest.find_by(uuid: request.headers['Authorization'])
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless user

    @chat_thread = user.chat_threads.find_or_initialize_by(thread_id: chat_thread_params[:thread_id])
    @chat_thread.assign_attributes(chat_thread_params.to_h.compact)

    if @chat_thread.save
      status = @chat_thread.previously_new_record? ? :created : :ok
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
    @current_thread = current_user.current_chat_thread
    render json: @current_thread
  end

  def set_current
    current_user.update(current_chat_thread_id: params[:thread_id])
    render json: { success: true }
  end

  private

  def set_chat_thread
    @chat_thread = current_user.chat_threads.find(params[:id])
  end

  def chat_thread_params
    params.require(:chat_thread).permit(:thread_id, :title, :last_message)
  end
end
