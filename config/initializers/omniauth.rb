# OmniAuth Configuration
# This file configures OmniAuth for use with Devise

# Set path prefix for OmniAuth routes
OmniAuth.config.path_prefix = '/omniauth'

# Configure OmniAuth to handle failures
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Allow both POST and GET requests for OmniAuth
OmniAuth.config.allowed_request_methods = [:post, :get]

# Hide the default OmniAuth form
OmniAuth.config.form_css = 'display: none'

if Rails.env.development?
  OmniAuth.config.full_host = 'http://localhost:3000'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
           ENV['GOOGLE_CLIENT_ID'], 
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             scope: 'userinfo.email,userinfo.profile',
             access_type: 'offline',
             prompt: 'consent',
             select_account: true,
             image_aspect_ratio: 'square',
             image_size: 50,
             name: 'google',
             provider_ignores_state: true,
             redirect_uri: "http://localhost:3000/omniauth/google_oauth2/callback"
           }
           
  provider :facebook,
           ENV['FACEBOOK_APP_ID'],
           ENV['FACEBOOK_APP_SECRET'],
           {
             scope: 'email,public_profile',
             info_fields: 'email,name',
             image_size: 'square',
             secure_image_url: true,
             provider_ignores_state: true,
             redirect_uri: "http://localhost:3000/omniauth/facebook/callback"
           }
end