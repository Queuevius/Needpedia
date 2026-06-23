class Api::V1::AiPromptsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_token

  def show
    prompt = if params[:version].present?
               AiPrompt.active_for_type(params[:ai_type])
                       .find_by(version: params[:version])
             else
               AiPrompt.active_for_type(params[:ai_type]).take
             end

    if prompt
      render json: {
        prompt: prompt.description
      }, status: :ok
    else
      render json: { error: "Prompt not found" }, status: :not_found
    end
  end

  private

  def validate_token
    token = ENV["AI_PROMPT_TOKEN"]
    if params[:token].blank? || token.blank? || params[:token] != token
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
