class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :masquerade_user!
  before_action :set_ransack, :read_message

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def set_ransack
    @q = Post.ransack(params[:q])
  end

  def read_message
    if current_user && params[:controller] == 'conversations' && params['action'] == 'index' || params['action'] == 'show'
      messages = current_user&.messages&.unread&.where(read_at: nil)
      messages.update_all read_at: Time.now if messages.present?
    end
  end
end
