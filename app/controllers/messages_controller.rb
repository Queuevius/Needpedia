class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    respond_to do |format|
      conversation = Conversation.find(message_params[:conversation_id])
      reciever = conversation.users.reject { |x| x == current_user }.last
      @message = Message.create(message_params.merge(receiver_id: reciever.id))
      create_activity(@message, 'message.create')
      create_admin_history_log(@message)
      message_read_path = message_read_path(@message.id)
      sender_html = ApplicationController.render partial: 'conversations/right_message', locals: {  message: @message, current_user: current_user }
      reciever_html = ApplicationController.render partial: 'conversations/left_message', locals: {  message: @message, current_user: current_user }
      reciever_conversation = ApplicationController.render partial: 'conversations/conversation', locals: { conversation: @message.conversation, user: reciever, current_user: current_user }
      sender_conversation = ApplicationController.render partial: 'conversations/conversation', locals: { conversation: @message.conversation, user: current_user, current_user: reciever }
      blocked_user_ids = reciever.blocked_users.pluck(:block_user_id)
      ActionCable.server.broadcast('conversation_channel', sender_html: sender_html, reciever_html: reciever_html, reciever_conversation: reciever_conversation, sender_conversation: sender_conversation, reciever_id: reciever.id, path: message_read_path, sender_id: current_user.id, sender_blocked: blocked_user_ids.include?(current_user.id))
      format.js
    end
  end

  def read
    respond_to do |format|
      @message = Message.find(params[:message_id])
      @message.update(read_at: Time.now);
      format.json { render json: { message: @message }, status: :ok }
    end
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :conversation_id, :body)
  end

  def create_activity(message, event)
    ActivityService.new(object: message, event: event, owner: current_user, ip: request.remote_ip).call
  end

  def create_admin_history_log(message)
    return unless message.user.admin?

    AdminHistory.create(
        user: message.user,
        action: "#{message.user.name} send message to #{message.receiver.name}",
        target_type: "Message",
        target_id: message.receiver.id,
        message: message.body,
        ip_address: request.remote_ip
    )
  end
end
