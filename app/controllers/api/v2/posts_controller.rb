class Api::V2::PostsController < Api::V2::BaseController
  before_action :authenticate_with_token!

  def index
    @posts = Post.all
    render json: @posts
  end

  def search
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true)
    render json: @posts
  end
  
  private

  # Token authentication method
  def authenticate_with_token!
    token = extract_token_from_header
    
    unless token && valid_token?(token)
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    
    @current_user = find_user_by_token(token)
    unless @current_user
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def extract_token_from_header
    # Extract token from Authorization header: "Bearer <token>"
    auth_header = request.headers['Authorization']
    return nil unless auth_header
    
    auth_header.split(' ').last if auth_header.start_with?('Bearer ')
  end

  def valid_token?(token)
    return false if token.blank?
    
    # Choose your authentication strategy:
    case Rails.application.config.auth_strategy&.to_sym
    when :jwt
      validate_jwt_token(token)
    when :database
      validate_database_token(token)
    when :api_key
      validate_api_key_token(token)
    when :devise_token_auth
      validate_devise_token_auth(token)
    else
      # Default to JWT if no strategy specified
      validate_jwt_token(token)
    end
  end

  # JWT Token Validation
  def validate_jwt_token(token)
    begin
      decoded_token = JWT.decode(
        token, 
        Rails.application.secret_key_base, 
        true, 
        { 
          algorithm: 'HS256',
          verify_expiration: true,
          verify_iat: true
        }
      )
      
      payload = decoded_token[0]
      
      # Check token expiration
      return false if payload['exp'] && Time.current.to_i > payload['exp']
      
      # Check if token was issued in the future (clock skew protection)
      return false if payload['iat'] && payload['iat'] > Time.current.to_i + 30
      
      # Optional: Check issuer
      return false if payload['iss'] && payload['iss'] != Rails.application.config.jwt_issuer
      
      true
    rescue JWT::ExpiredSignature
      Rails.logger.warn "JWT token expired"
      false
    rescue JWT::InvalidIatError
      Rails.logger.warn "JWT token issued at invalid time"
      false
    rescue JWT::DecodeError => e
      Rails.logger.warn "JWT decode error: #{e.message}"
      false
    end
  end

  # Database Token Validation
  def validate_database_token(token)
    # Validate token format (optional)
    return false unless token.match?(/\A[a-zA-Z0-9_-]{32,}\z/)
    
    user = User.find_by(auth_token: token)
    return false unless user
    
    # Check if token is expired (if you have token_expires_at column)
    if user.respond_to?(:token_expires_at) && user.token_expires_at
      return false if user.token_expires_at < Time.current
    end
    
    # Check if user is active
    return false unless user.active?
    
    # Update last_seen_at (optional)
    user.touch(:last_seen_at) if user.respond_to?(:last_seen_at)
    
    true
  end

  # API Key Validation
  def validate_api_key_token(token)
    # Validate API key format
    return false unless token.match?(/\A[a-zA-Z0-9]{40}\z/)
    
    api_key = ApiKey.find_by(key: token)
    return false unless api_key
    
    # Check if API key is active
    return false unless api_key.active?
    
    # Check expiration
    return false if api_key.expires_at && api_key.expires_at < Time.current
    
    # Check rate limiting (if implemented)
    return false if api_key.rate_limited?
    
    # Update usage statistics
    api_key.increment!(:usage_count)
    api_key.touch(:last_used_at)
    
    true
  end

  # Devise Token Auth Validation (for devise_token_auth gem)
  def validate_devise_token_auth(token)
    return false unless token.present?
    
    # Extract headers needed for devise_token_auth
    uid = request.headers['uid']
    client = request.headers['client']
    
    return false unless uid.present? && client.present?
    
    user = User.find_by(email: uid)
    return false unless user
    
    # Validate token using devise_token_auth
    user.valid_token?(token, client)
  end

  def find_user_by_token(token)
    case Rails.application.config.auth_strategy&.to_sym
    when :jwt
      find_user_by_jwt_token(token)
    when :database
      find_user_by_database_token(token)
    when :api_key
      find_user_by_api_key_token(token)
    when :devise_token_auth
      find_user_by_devise_token_auth(token)
    else
      # Default to JWT
      find_user_by_jwt_token(token)
    end
  end

  # Find user by JWT token
  def find_user_by_jwt_token(token)
    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
      payload = decoded_token[0]
      
      user_id = payload['user_id'] || payload['sub']
      User.find_by(id: user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end

  # Find user by database token
  def find_user_by_database_token(token)
    User.find_by(auth_token: token)
  end

  # Find user by API key
  def find_user_by_api_key_token(token)
    api_key = ApiKey.find_by(key: token)
    api_key&.user
  end

  # Find user by devise token auth
  def find_user_by_devise_token_auth(token)
    uid = request.headers['uid']
    User.find_by(email: uid)
  end

  # Helper method to generate secure tokens (for database strategy)
  def self.generate_auth_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(auth_token: token)
    end
  end

  # Helper method to generate JWT token (for JWT strategy)
  def self.generate_jwt_token(user, expires_in = 24.hours)
    payload = {
      user_id: user.id,
      email: user.email,
      iat: Time.current.to_i,
      exp: (Time.current + expires_in).to_i,
      iss: Rails.application.config.jwt_issuer || 'your_app_name'
    }
    
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end