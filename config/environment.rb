# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
ActionMailer::Base.smtp_settings = {
  address:              'in-v3.mailjet.com',
  port:                 587,
  domain:               (ENV['MAILJET_DOMAIN'] || ENV['DOMAIN']),
  authentication:       :plain,
  user_name:            ENV['MAILJET_API_KEY'],
  password:             ENV['MAILJET_SECRET_KEY'],
  enable_starttls_auto: true
}