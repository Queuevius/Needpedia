# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
ActionMailer::Base.smtp_settings = {
  domain:         ENV['DOMAIN'],
  address:        'smtp.sendgrid.net',
  port:            587,
  authentication: :plain,
  user_name:      ENV['USER_NAME'],
  password:       ENV['PASSWORD']
}