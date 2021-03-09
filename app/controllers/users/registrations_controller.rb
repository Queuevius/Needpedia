class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create, :update] # Change this to be any actions you want to protect.
  prepend_after_action :save_questionnaire_data, only: [:create]

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
    questionnaire = Questionnaire.find(params[:questionnaire_id])
    questionnaire.questions.each do |q|
      q.answers.create(body: params["answer_#{q.id}"], user_id: resource.id)
    end
  end
end