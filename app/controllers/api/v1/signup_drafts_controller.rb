class Api::V1::SignupDraftsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_token
  before_action :check_rate_limit

  RATE_LIMIT = 5
  RATE_WINDOW = 10.minutes

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

  # Abuse guard: sliding window per caller IP. In-process counter (no new gem,
  # no schema change). Sufficient for this bridge endpoint, which has a single
  # legitimate caller (the greeter server) and a secret token gate in front.
  def check_rate_limit
    return if performed?

    ip = request.remote_ip
    now = Time.current
    self.class.rate_mutex.synchronize do
      hits = self.class.rate_store[ip]
      hits.reject! { |t| t < now - RATE_WINDOW }
      if hits.size >= RATE_LIMIT
        render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
        return
      end
      hits << now
    end
  end

  class << self
    def rate_store
      @rate_store ||= Hash.new { |h, k| h[k] = [] }
    end

    def rate_mutex
      @rate_mutex ||= Mutex.new
    end

    # Test hook: the in-process store outlives a single test, so reset it.
    def reset_rate_store!
      rate_mutex.synchronize { rate_store.clear }
    end
  end
end
