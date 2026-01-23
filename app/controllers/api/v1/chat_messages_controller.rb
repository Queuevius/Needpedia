class Api::V1::ChatMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_actor
  before_action :set_chat_thread

  def index
    messages = @chat_thread.chat_messages.order(:created_at)
    render json: {
      thread_id: @chat_thread.thread_id,
      messages: messages.as_json(only: [:id, :role, :content, :created_at, :metadata])
    }
  end

  def create
    permitted_messages = message_params

    if permitted_messages.empty?
      return render json: { error: 'messages parameter is required' }, status: :unprocessable_entity
    end

    ChatMessage.transaction do
      permitted_messages.each do |attrs|
        @chat_thread.chat_messages.create!(attrs)
      end

      update_thread_metadata(permitted_messages)
    end

    render json: { success: true }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_actor
    token = request.headers['Authorization'].to_s
    @actor = User.find_by(uuid: token) || Guest.find_by(uuid: token)
    return if @actor

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def set_chat_thread
    return unless @actor

    thread_identifier = params[:thread_id].presence || params.dig(:chat_thread, :thread_id)
    @chat_thread = @actor.chat_threads.find_by(thread_id: thread_identifier)
    return if @chat_thread

    render json: { error: 'Chat thread not found' }, status: :not_found
  end

  def message_params
    Array(params[:messages]).filter_map do |message|
      parameterized = message.is_a?(ActionController::Parameters) ? message : ActionController::Parameters.new(message)
      permitted = parameterized.permit(:role, :content, metadata: {})
      next unless permitted[:role].present? && permitted[:content].present?

      {
        role: permitted[:role],
        content: permitted[:content],
        metadata: permitted[:metadata] || {}
      }
    end
  end

  def update_thread_metadata(messages)
    title = params[:title].presence
    last_message = params[:last_message].presence || messages.last&.dig(:content)

    updates = {}
    updates[:title] = title if title.present?
    updates[:last_message] = last_message if last_message.present?

    @chat_thread.update(updates) if updates.present?
  end
end

