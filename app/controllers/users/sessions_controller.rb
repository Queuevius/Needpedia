class Users::SessionsController < Devise::SessionsController
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
end