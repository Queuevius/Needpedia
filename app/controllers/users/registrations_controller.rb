class Users::RegistrationsController < Devise::RegistrationsController
  # prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.
  before_action :check_account_status, only: [:new, :create]
  prepend_after_action :save_questionnaire_data, only: [:create]

  def update
    time = params[:daily_notification_time]
    if time.present?
      parsed_time = Time.parse(time)
      @user.update(daily_notification_time: parsed_time) if parsed_time
    end
    super
  end

  private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      resource.validate # Look for any other validation errors besides reCAPTCHA
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
    end
  end

  def save_questionnaire_data
    # add custom create logic here
    return unless params[:questionnaire_id].present?

    questionnaire = Questionnaire.find(params[:questionnaire_id])
    questionnaire.questions.each do |q|
      q.answers.create(body: params["answer_#{q.id}"], user_id: resource.id)
    end
  end

  def check_account_status
    redirect_to root_path, alert: "Can't perform this action right now sorry for the inconvenience." and return if Setting.accounts_freezed
  end

  def build_resource(hash = {})
    self.resource = resource_class.new_with_session(hash, session)
    questionnaire = Questionnaire.first

    # Jumpstart: Skip email confirmation on registration.
    #   Require confirmation when user changes their email only
    resource.skip_confirmation_notification! if questionnaire&.active?
  end
end
