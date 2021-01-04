class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    respond_to do |format|
      @message = Message.create(message_params)
      reciever = @message.conversation.users.reject { |x| x == current_user }.last
      message_read_path = message_read_path(@message.id)
      html = ApplicationController.render partial: 'conversations/message', locals: {  message: @message, current_user: current_user }
      ActionCable.server.broadcast('conversation_channel', html: html, reciever_id: reciever.id, path: message_read_path)
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
end
