class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_nuclear_note
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :masquerade_user!
  before_action :set_ransack, :conversations

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :message_notifications, :track_notifications, :daily_notifications, :all_notifications])
  end

  def set_ransack
    @q = Post.ransack(params[:q])
    @u = User.ransack(params[:q])
  end

  def conversations
    @conversations = current_user&.conversations.includes(:messages, :users).order('messages.created_at DESC') if current_user
  end

  def check_nuclear_note
    redirect_to nuclear_note_path if Setting.nuclear_note_active?
  end
end
