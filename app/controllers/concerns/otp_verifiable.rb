module OtpVerifiable
  extend ActiveSupport::Concern

  included do
    before_action :check_otp
  end

  private

  def check_otp
    return if otp_verified?

    if current_user&.otp_required_for_login
      handle_otp_verification
    else
      handle_otp_setup
    end
  end

  def handle_otp_setup
    session[:user_return_to] = request.original_url
    flash[:alert] = "Please complete the two-factor authentication setup to continue."
    redirect_to otp_path
  end

  def handle_otp_verification
    session[:user_return_to] = request.original_url
    flash[:alert] = "Please complete the two-factor authentication setup to continue."

    if params[:otp_attempt].present?
      verify_otp
    elsif params[:backup_code].present?
      verify_backup_code
    else
      redirect_to new_otp_verification_path
    end
  end

  def verify_otp
    user = current_user

    if user&.validate_and_consume_otp!(params[:otp_attempt])
      complete_otp_verification(user)
    else
      flash[:alert] = 'Invalid OTP code.'
      redirect_to new_otp_verification_path
    end
  end

  def verify_backup_code
    if backup_code_valid?(params[:backup_code])
      complete_otp_verification(current_user)
    else
      flash[:alert] = 'Invalid backup code.'
      redirect_to new_otp_verification_path
    end
  end

  def backup_code_valid?(code)
    current_user.otp_backup_codes.any? {|stored_code| BCrypt::Password.new(stored_code).is_password?(code)}
  end

  def complete_otp_verification(user)
    session[:otp_verified] = true
    session[:otp_verified_at] = Time.current
    sign_in(:user, user)
    redirect_to session.delete(:user_return_to) || root_path, notice: 'OTP verified successfully.'
  end

  def otp_verified?
    verified_at = session[:otp_verified_at].present? ? Time.parse(session[:otp_verified_at]) : nil
    verified_at && Time.current < verified_at + 1.week
  end
end
