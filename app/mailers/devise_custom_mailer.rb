class DeviseCustomMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  # If there is an object in your application that returns a contact email, you can use it as follows
  # Note that Devise passes a Devise::Mailer object to your proc, hence the parameter throwaway (*).

  def confirmation_instructions(record, token, opts = {})
    email_template = EmailTemplate.find_by(name: 'confirmation_instructions')
    mail = super
    mail.subject = email_template.present? ? email_template.subject : 'Confirmation instructions'
    mail
  end

  def reset_password_instructions(record, token, opts = {})
    email_template = EmailTemplate.find_by(name: 'reset_password_instructions')
    mail = super
    mail.subject = email_template.present? ? email_template.subject : 'Reset password instructions'
    mail
  end

  def unlock_instructions(record, token, opts = {})
    email_template = EmailTemplate.find_by(name: 'unlock_instructions')
    mail = super
    mail.subject = email_template.present? ? email_template.subject : 'Unlock instructions'
    mail
  end

  def email_changed(record, opts = {})
    email_template = EmailTemplate.find_by(name: 'email_changed')
    mail = super
    mail.subject = email_template.present? ? email_template.subject : 'Email Changed'
    mail
  end

  def password_change(record, opts = {})
    email_template = EmailTemplate.find_by(name: 'password_change')
    mail = super
    mail.subject = email_template.present? ? email_template.subject : 'Password Changed'
    mail
  end
end