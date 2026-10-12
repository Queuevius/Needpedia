class Api::V1::SignupDraftsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_token

  def create
    draft = SignupDraft.create_draft!(
      name: draft_params[:name].to_s.strip,
      email: draft_params[:email].to_s.strip
    )
    render json: { draft_token: draft.token }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue ActionController::ParameterMissing
    render json: { errors: ['param is missing or the value is empty'] }, status: :unprocessable_entity
  end

  private

  def draft_params
    params.require(:signup_draft).permit(:name, :email)
  end

  def validate_token
    expected = ENV['SIGNUP_BRIDGE_TOKEN']
    provided = params[:bridge_token]
    unauthorized = expected.blank? || provided.blank? ||
      !ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(provided.to_s),
        ::Digest::SHA256.hexdigest(expected)
      )
    render json: { error: 'Unauthorized' }, status: :unauthorized if unauthorized
  end
end
