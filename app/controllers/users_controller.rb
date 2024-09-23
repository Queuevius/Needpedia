class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show_otp verify_otp verify_backup_code]


  def show_otp
    # Render the OTP entry page
  end

  def verify_otp
    verifier = Rails.application.message_verifier(:otp_session)
    user_id = verifier.verify(session[:otp_token])
    user = User.find(user_id)

    if user.validate_and_consume_otp!(params[:otp_attempt])
      # OTP is correct. Log the user in
      sign_in(:user, user)
      redirect_to root_path, notice: 'Logged in successfully!'
    else
      flash[:alert] = 'Invalid OTP code.'
      redirect_to new_user_session_path
    end
  end

  def enable_otp_show_qr
    if current_user.otp_required_for_login
      redirect_to edit_user_registration_path, alert: '2FA is already enabled.'
    else
      current_user.update(
          otp_required_for_login: true
      )
      current_user.save!
    end
  end

  def enable_otp_verify
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.otp_required_for_login = true
      current_user.save!
      redirect_to session.delete(:user_return_to) || root_path, notice: '2FA enabled successfully.'
    else
      redirect_to request.referrer || root_path, alert: 'Invalid OTP code.'
    end
  end

  #This verifies the backup codes and displays the QR code.
  def verify_backup_code_show_qrcode
    user = current_user
    code = params[:backup_code]
    if user.otp_backup_codes.any? { |stored_code| BCrypt::Password.new(stored_code).is_password?(code) }
      session[:backup_codes_verified] = Time.current + 20.minutes
      redirect_to request.referrer || root_path, notice: 'Verify successfully.'
    else
      redirect_to request.referrer || root_path, alert: 'Invalid backup code.'
    end
  end

  #verify the backup code for login
  def verify_backup_code
    verifier = Rails.application.message_verifier(:otp_session)
    user_id = verifier.verify(session[:otp_token])
    user = User.find(user_id)
    code = params[:backup_code]
    if user.otp_backup_codes.any? { |stored_code| BCrypt::Password.new(stored_code).is_password?(code) }
      sign_in(:user, user)
      redirect_to root_path, notice: 'Successfully logged in with backup code!'
    else
      flash.now[:alert] = 'Invalid backup code.'
      redirect_to new_user_session_path
    end
  end
end