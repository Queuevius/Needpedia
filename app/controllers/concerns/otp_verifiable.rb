module OtpVerifiable
  extend ActiveSupport::Concern

  included do
    before_action :check_otp
  end

  private

  def check_otp
    return unless current_user && !current_user.otp_required_for_login
    session[:user_return_to] = request.original_url
    flash[:alert] = "Please complete the two-factor authentication setup to continue."
    redirect_to otp_path
    true
  end
end
