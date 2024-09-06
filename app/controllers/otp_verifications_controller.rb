class OtpVerificationsController < ApplicationController
  include OtpVerifiable

  skip_before_action :check_otp, only: [:new, :create]

  def new
  end

  def create
    if params[:otp_attempt].present?
      verify_otp
    elsif params[:backup_code].present?
      verify_backup_code
    else
      flash[:alert] = "Please provide OTP or Backup Code."
      redirect_to new_otp_verification_path
    end
  end
end
