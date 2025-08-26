class Api::V1::AuthController < ApplicationController
  resource_description do
    name 'API v1 - Auth'
    short 'CORS preflight handler'
    api_versions 'v1'
  end

  api :OPTIONS, '/api/v1/auth/sign_in', 'CORS preflight for sign-in'
  description 'Responds with allowed methods/headers for cross-origin requests.'
  def options_request
    # Set the allowed origins for cross-origin requests
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'content-type, Authorization'
    head :ok
  end
end