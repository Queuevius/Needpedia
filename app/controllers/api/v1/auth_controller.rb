class Api::V1::AuthController < ApplicationController
  def options_request
    # Set the allowed origins for cross-origin requests
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'content-type, Authorization'
    head :ok
  end
end