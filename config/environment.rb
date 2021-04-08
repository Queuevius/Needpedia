# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
ActionMailer::Base.smtp_settings = {
  domain:         'sessioncontrol.co',
  address:        'smtp.sendgrid.net',
  port:            587,
  authentication: :plain,
  user_name:      'apikey',
  password:       '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'
}