class ConversationsController < ApplicationController
  before_action :authenticate_user!
  def index
    @f = User.ransack(params[:q])
    @conversations = current_user.conversations.includes(:messages, :users).order('messages.created_at DESC')
    @message = Message.new
    @conversation = @conversations.first
  end

  def show
    @f = User.ransack(params[:q])
    @message = Message.new
    @conversations = current_user.conversations.includes(:messages, :users).order('messages.created_at DESC')
    @conversation = Conversation.find(params[:id])
  end

  def create
    receiver = User.find(params[:receiver_id])
    conversation = current_user.conversations.includes(:users).where(users: {id: receiver.id}).first
    if conversation.nil?
      conversation = Conversation.new
      conversation.users << current_user << receiver
      conversation.save
    end
    redirect_to conversation_path(conversation)
  end
end
