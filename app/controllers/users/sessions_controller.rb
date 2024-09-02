class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_captcha, only: [:create]
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

      if resource && resource.active_for_authentication?
        # If the user has 2FA enabled
        if resource.otp_required_for_login
          verifier = Rails.application.message_verifier(:otp_session)
          token = verifier.generate(resource.id)
          session[:otp_token] = token

          # Logout the user to wait for the 2FA verification
          sign_out(resource_name)

          # Redirect the user to the OTP entry page
          redirect_to user_otp_path and return
        else
          # If 2FA is not required, log the user in
          set_flash_message!(:notice, :signed_in)
          sign_in(resource_name, resource)
          yield resource if block_given?
          respond_with resource, location: after_sign_in_path_for(resource) and return
        end
      end
    end
  end

  def after_sign_in_path_for(resource)
    resource.last_login_at.nil? ? (resource.update(last_login_at: Time.now); ai_path) : super
  end

  private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_in_params
      respond_with_navigational(resource) {render :new}
    end
  end
end
