class Api::V1::TokensController < ApplicationController
  def create
    record = User.find_by(uuid: params[:utoken]) || Guest.find_by(uuid: params[:utoken])
    tokens = record&.ai_tokens.last.tokens_count || 0
    if tokens.positive?
      render json: {tokens: tokens}, status: :ok
    else
      render json: {tokens: 0, message: 'Insufficient tokens'}, status: :unprocessable_entity
    end
  end


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
