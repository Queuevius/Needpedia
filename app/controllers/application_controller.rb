class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :check_nuclear_note
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :masquerade_user!
  before_action :set_ransack, :conversations
  before_action :check_blocked_ip
  before_action :set_chatbot_url

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :message_notifications, :track_notifications, :daily_notifications, :all_notifications, :default_group_id, :otp_attempt])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
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

  def check_blocked_ip
    return unless blocked_ip?
    render plain: "Access Denied", status: :forbidden
  end

  def set_chatbot_url
    track_guest
    @user = current_user || current_guest
    @token = @user&.uuid
    @chatbot_url = current_user ? ENV['CHATBOT_URL'] : ENV['GUEST_CHATBOT_URL']
  end

  def track_guest
    return if current_user || blocked_ip?

    @current_guest = Guest.find_or_create_by(ip: request.remote_ip) do |guest|
      guest.uuid = SecureRandom.uuid
      guest.fingerprint = SecureRandom.hex(16)
    end
  end

  def current_guest
    @current_guest
  end

  private

  def blocked_ip?
    BlockedIp.exists?(ip: request.remote_ip)
  end
end
