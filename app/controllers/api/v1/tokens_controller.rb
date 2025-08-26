class Api::V1::TokensController < ApplicationController
  resource_description do
    name 'API v1 - Tokens'
    short 'AI token balance endpoints'
    api_versions 'v1'
  end

  api :POST, '/api/v1/tokens', 'Get available tokens for a user/guest'
  param :utoken, String, required: true, desc: 'User or Guest UUID'
  def create
    record = User.find_by(uuid: params[:utoken]) || Guest.find_by(uuid: params[:utoken])
    tokens = record&.ai_tokens.last.tokens_count || 0
    if tokens.positive?
      render json: {tokens: tokens}, status: :ok
    else
      render json: {tokens: 0, message: 'Insufficient tokens'}, status: :unprocessable_entity
    end
  end


  api :POST, '/api/v1/tokens/decrease', 'Decrease token balance'
  param :utoken, String, required: true, desc: 'User or Guest UUID'
  param :decrement_by, Integer, required: true, desc: 'How many tokens to subtract'
  def decrease
    record = User.find_by(uuid: params[:utoken]) || Guest.find_by(uuid: params[:utoken])
    if record.nil?
      return render json: { message: 'Unauthenticated' }, status: :unauthorized
    end
    decrement_by = params[:decrement_by].to_i
    tokens = record&.ai_tokens.last
    tokens_count = tokens&.tokens_count
    if decrement_by <= 0
      return render json: {message: 'Invalid decrement value'}, status: :bad_request
    end
    tokens.update!(tokens_count: tokens_count - decrement_by)
    render json: {tokens: record&.ai_tokens.last&.tokens_count}, status: :ok
  rescue StandardError => e
    render json: {message: e.message}, status: :internal_server_error
  end
end
