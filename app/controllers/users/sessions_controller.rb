class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_captcha, only: [:create]
  before_action :log_failed_login_attempt, only: [:create]

  def create
    email = params[:user][:email]
    user = User.find_by_email(email)
    if user && user&.disabled
      flash[:alert] = 'Your Account has been terminated.'
      redirect_to root_path
    elsif user && !user.admin && Setting.accounts_freezed
      sign_out user
      redirect_to root_path, alert: "Can't perform this action right now sorry for the inconvenience."
    else
      self.resource = warden.authenticate!(auth_options.merge(strategy: :password_authenticatable))

      # if resource && resource.active_for_authentication?
      #   # If the user has 2FA enabled
      #   if resource.otp_required_for_login
      #     verifier = Rails.application.message_verifier(:otp_session)
      #     token = verifier.generate(resource.id)
      #     session[:otp_token] = token
      #
      #     # Logout the user to wait for the 2FA verification
      #     sign_out(resource_name)
      #
      #     # Redirect the user to the OTP entry page
      #     redirect_to user_otp_path and return
      #   else
      #     # If 2FA is not required, log the user in
      #     set_flash_message!(:notice, :signed_in)
      #     sign_in(resource_name, resource)
      #     yield resource if block_given?
      #     respond_with resource, location: after_sign_in_path_for(resource) and return
      #   end
      # end
      super
    end
  end

  def after_sign_in_path_for(resource)
    resource.last_login_at.nil? ? (resource.update(last_login_at: Time.now); ai_path) : super
  end

  private

  def check_captcha
    unless validate_turnstile(params['cf-turnstile-response'], request.remote_ip)
      self.resource = resource_class.new sign_in_params
      resource.validate # Look for any other validation errors besides reCAPTCHA
      resource.errors.add(:base, "Something went wrong with CAPTCHA validation. Please try again.") if resource.errors.empty?
      respond_with_navigational(resource) {render :new}
    end
  end

  def log_failed_login_attempt
    ip = request.remote_ip
    return if BlockedIp.exists?(ip: ip)

    return unless request.post? && params[:user][:email].present?

    user = User.find_by(email: params[:user][:email])
    return if user&.valid_password?(params[:user][:password])

    LoginAttempt.create(
        ip_address: request.remote_ip,
        attempted_at: Time.current,
        success: false
    )

    failed_attempts_count = LoginAttempt.where(ip_address: request.remote_ip, success: false )
                                .where('created_at >= ?', 24.hour.ago)
                                .count
    if failed_attempts_count > 10
      BlockedIp.find_or_create_by(ip: request.remote_ip)
      AdminMailer.ip_blacklisted(request.remote_ip).deliver_later
      render json: { error: 'Too many failed login attempts. Please try again later.' }, status: :too_many_requests
    end
  end

  def validate_turnstile(token, ip)
    uri = URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    response = Net::HTTP.post_form(uri, {
        'secret' => ENV['CLOUDFLARE_SECRET_KEY'],
        'response' => token,
        'remoteip' => ip
    })

    outcome = JSON.parse(response.body)
    outcome['success']
  end

end
