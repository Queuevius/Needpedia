class Users::SessionsController < Devise::SessionsController
  prepend_before_action :check_captcha, only: [:create]
  def create
    email = params[:user][:email]
    user = User.find_by_email(email)
    if user && user&.disabled
      flash[:alert] = 'Your Account has been terminated.'
      redirect_to root_path
    else
      super
    end
  end

  private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_in_params
      respond_with_navigational(resource) { render :new }
    end
  end
end