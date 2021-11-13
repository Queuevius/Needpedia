class NuclearNoteController < ActionController::Base
  layout 'application'

  def index
    @q = Post.ransack(params[:q])
    @u = User.ransack(params[:q])
    @conversations = current_user&.conversations.includes(:messages, :users).order('messages.created_at DESC') if current_user
    @nuclear_note = Setting.first&.nuclear_note
  end
end
