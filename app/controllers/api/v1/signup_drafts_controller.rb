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
    return unless unauthorized

    # Brute-force cap: bad tokens share a per-IP counter. A correct token
    # bypasses this entirely, so lockout can't DoS the real caller.
    if auth_failures_over_limit?
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Abuse guards: sliding-window per caller IP. In-process counters (no new
  # gem, no schema change). Success drafts and failed-auth guesses are capped
  # separately so neither path exhausts the other.
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

  def auth_failures_over_limit?
    ip = request.remote_ip
    now = Time.current
    self.class.rate_mutex.synchronize do
      fails = self.class.auth_fail_store[ip]
      fails.reject! { |t| t < now - RATE_WINDOW }
      fails << now
      fails.size > RATE_LIMIT
    end
  end

  class << self
    def rate_store
      @rate_store ||= Hash.new { |h, k| h[k] = [] }
    end

    def auth_fail_store
      @auth_fail_store ||= Hash.new { |h, k| h[k] = [] }
    end

    def rate_mutex
      @rate_mutex ||= Mutex.new
    end

    # Test hook: the in-process stores outlive a single test, so reset them.
    def reset_rate_store!
      rate_mutex.synchronize do
        rate_store.clear
        auth_fail_store.clear
      end
    end
  end
end
