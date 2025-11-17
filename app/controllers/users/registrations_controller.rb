class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  before_action :check_gibberish, only: [:create]
  before_action :check_account_status, only: [:new, :create]
  prepend_after_action :save_questionnaire_data, only: [:create]
  include GibberishHelper

  def update
    time = params[:daily_notification_time]
    if time.present?
      parsed_time = Time.parse(time)
      @user.update(daily_notification_time: parsed_time) if parsed_time
    end
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    redirect_to edit_registration_path(resource_name) and return if should_disable_otp? && !disable_otp!

    process_standard_update
  end

  private

  def check_captcha
    unless validate_turnstile(params['cf-turnstile-response'], request.remote_ip)
      self.resource = resource_class.new sign_up_params
      resource.validate # Look for any other validation errors besides reCAPTCHA
      resource.errors.add(:base, "Something went wrong with CAPTCHA validation. Please try again.") if resource.errors.empty?
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

  def check_gibberish
    return unless params[:questionnaire_id].present?

    questionnaire = Questionnaire.find(params[:questionnaire_id])
    questionnaire.questions.each do |q|
      if gibberish?(params["answer_#{q.id}"])
        redirect_to root_path, alert: 'Sorry, we are not satisfied with the information you provided.' and return
      end
    end

  end

  def should_disable_otp?
    resource.otp_required_for_login && params[:user][:otp_attempt].present? && params[:user][:current_password].present?
  end

  def disable_otp!
    otp_attempt = params[:user][:otp_attempt]
    current_password = params[:user][:current_password]

    if resource.validate_and_consume_otp!(otp_attempt) && resource.valid_password?(current_password)
      resource.otp_required_for_login = false
      resource.save!
      set_flash_message!(:notice, :otp_disabled)
      true
    else
      set_flash_message!(:alert, appropriate_error_message(otp_attempt, current_password))
      false
    end
  end

  def appropriate_error_message(otp_attempt, current_password)
    return :invalid_otp unless resource.validate_and_consume_otp!(otp_attempt)
    return :invalid_password unless resource.valid_password?(current_password)

    :invalid_otp_and_password
  end

  def process_standard_update
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def validate_turnstile(token, ip)
    return true if skip_turnstile_in_development?

    uri = URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    response = Net::HTTP.post_form(uri, {
        'secret' => ENV['CLOUDFLARE_SECRET_KEY'],
        'response' => token,
        'remoteip' => ip
    })

    outcome = JSON.parse(response.body)
    outcome['success']
  end

  def skip_turnstile_in_development?
    Rails.env.development? && (ENV['CLOUDFLARE_SECRET_KEY'].blank? || ENV['CLOUDFLARE_SITE_KEY'].blank?)
  end

end
