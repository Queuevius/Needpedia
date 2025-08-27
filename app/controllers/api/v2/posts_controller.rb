class Api::V2::PostsController < Api::V2::BaseController
  resource_description do
    name 'API v2 - Posts'
    short 'JWT or token-auth endpoints for posts'
    description <<-EOS
      API endpoints for managing posts with multiple authentication strategies.
      
      Supports the following authentication methods:
      - JWT Token (default)
      - Database Token
      - API Key
      - Devise Token Auth
      
      All endpoints require authentication via Bearer token in Authorization header.
    EOS
    api_versions 'v2'
    api_base_url '/api/v2'
    formats ['json']
  end

  before_action :authenticate_with_token!

  api :GET, '/api/v2/posts', 'List all posts'
  description <<-EOS
    Returns a list of all posts in the system. Requires valid authentication token.
    
    == Authentication
    All authentication strategies are supported:
    - JWT Token: Standard JWT with HS256 algorithm
    - Database Token: Custom token stored in user record
    - API Key: 40-character alphanumeric key
    - Devise Token Auth: Requires uid and client headers
  EOS
  header 'Authorization', 'Bearer token for authentication', required: true
  header 'uid', 'User email (required for devise_token_auth)', required: false
  header 'client', 'Client ID (required for devise_token_auth)', required: false
  error code: 401, desc: 'Unauthorized - Invalid or missing token'
  error code: 403, desc: 'Forbidden - Token valid but insufficient permissions'
  example <<-EOS
    curl -X GET https://your-domain.com/api/v2/posts \\
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \\
      -H "Content-Type: application/json"
      
    Response (200):
    [
      {
        "id": 1,
        "title": "Sample Post Title",
        "content": "This is the content of the post...",
        "author_id": 123,
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-15T10:30:00Z"
      },
      {
        "id": 2,
        "title": "Another Post",
        "content": "Another post content...",
        "author_id": 456,
        "created_at": "2024-01-16T14:20:00Z",
        "updated_at": "2024-01-16T14:20:00Z"
      }
    ]
    
    Error Response (401):
    {
      "error": "Unauthorized"
    }
  EOS

  def index
    @posts = Post.all
    render json: @posts
  end

  api :GET, '/api/v2/posts/:id', 'Get a post by ID'
  description <<-EOS
    Returns a single post by its ID. Requires valid authentication token.
    
    == Authentication
    All authentication strategies are supported:
    - JWT Token: Standard JWT with HS256 algorithm
    - Database Token: Custom token stored in user record
    - API Key: 40-character alphanumeric key
    - Devise Token Auth: Requires uid and client headers
  EOS
  header 'Authorization', 'Bearer token for authentication', required: true
  header 'uid', 'User email (required for devise_token_auth)', required: false
  header 'client', 'Client ID (required for devise_token_auth)', required: false
  param :id, Integer, desc: 'ID of the post', required: true
  error code: 401, desc: 'Unauthorized - Invalid or missing token'
  error code: 404, desc: 'Not Found - Post does not exist'
  example <<-EOS
    curl -X GET https://your-domain.com/api/v2/posts/123 \
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
      -H "Content-Type: application/json"
    
    Response (200):
    {
      "id": 123,
      "title": "Sample Post Title",
      "content": "This is the content of the post...",
      "author_id": 456,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-16T14:20:00Z"
    }
    
    Error Response (404):
    {
      "error": "Not Found"
    }
  EOS
  def show
    post = Post.find_by(id: params[:id])
    if post
      render json: post
    else
      render json: {error: 'Not Found'}, status: :not_found
    end
  end

  api :GET, '/api/v2/posts/search', 'Search posts using Ransack'
  description <<-EOS
    Search and filter posts using Ransack gem query parameters. 
    Returns filtered results based on the provided search criteria.
    
    == Ransack Predicates
    Common predicates you can use:
    - _eq: Equal to
    - _cont: Contains (case insensitive)
    - _start: Starts with
    - _end: Ends with
    - _gt: Greater than
    - _gteq: Greater than or equal to
    - _lt: Less than
    - _lteq: Less than or equal to
    - _in: In array
    - _null: Is null
    - _not_null: Is not null
    
    == Sorting
    Use q[s] parameter for sorting:
    - q[s]=created_at desc
    - q[s]=title asc
    - q[s]=author_id desc
    
    == Examples
    - Search by title: ?q[title_cont]=rails
    - Search by author: ?q[author_id_eq]=123
    - Date range: ?q[created_at_gteq]=2024-01-01&q[created_at_lteq]=2024-12-31
    - Multiple authors: ?q[author_id_in][]=1&q[author_id_in][]=2
  EOS
  param :q, Hash, desc: 'Ransack query parameters for filtering and sorting posts', required: false do
    param :title_cont, String, desc: 'Title contains text (case insensitive)', required: false
    param :title_eq, String, desc: 'Title equals exact text', required: false
    param :title_start, String, desc: 'Title starts with text', required: false
    param :title_end, String, desc: 'Title ends with text', required: false
    param :content_cont, String, desc: 'Content contains text', required: false
    param :author_id_eq, Integer, desc: 'Author ID equals', required: false
    param :author_id_in, Array, desc: 'Author ID in list', required: false
    param :created_at_gteq, String, desc: 'Created at greater than or equal to date (YYYY-MM-DD)', required: false
    param :created_at_lteq, String, desc: 'Created at less than or equal to date (YYYY-MM-DD)', required: false
    param :created_at_gt, String, desc: 'Created at greater than date', required: false
    param :created_at_lt, String, desc: 'Created at less than date', required: false
    param :updated_at_gteq, String, desc: 'Updated at greater than or equal to date', required: false
    param :updated_at_lteq, String, desc: 'Updated at less than or equal to date', required: false
    param :id_eq, Integer, desc: 'Post ID equals', required: false
    param :id_gt, Integer, desc: 'Post ID greater than', required: false
    param :id_lt, Integer, desc: 'Post ID less than', required: false
    param :id_in, Array, desc: 'Post ID in list', required: false
    param :s, String, desc: 'Sort by field and direction (e.g., "created_at desc", "title asc")', required: false
  end
  header 'Authorization', 'Bearer token for authentication', required: true
  header 'uid', 'User email (required for devise_token_auth)', required: false
  header 'client', 'Client ID (required for devise_token_auth)', required: false
  error code: 401, desc: 'Unauthorized - Invalid or missing token'
  error code: 422, desc: 'Unprocessable Entity - Invalid search parameters'
  example <<-EOS
    # Simple title search
    curl -X GET "https://your-domain.com/api/v2/posts/search?q[title_cont]=rails" \\
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \\
      -H "Content-Type: application/json"
    
    # Complex search with multiple filters
    curl -X GET "https://your-domain.com/api/v2/posts/search?q[title_cont]=guide&q[author_id_eq]=123&q[created_at_gteq]=2024-01-01&q[s]=created_at%20desc" \\
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \\
      -H "Content-Type: application/json"
    
    # Search multiple authors
    curl -X GET "https://your-domain.com/api/v2/posts/search?q[author_id_in][]=1&q[author_id_in][]=2&q[s]=title%20asc" \\
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \\
      -H "Content-Type: application/json"
    
    Success Response (200):
    [
      {
        "id": 1,
        "title": "Rails Guide",
        "content": "A comprehensive rails guide...",
        "author_id": 123,
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-15T10:30:00Z"
      }
    ]
    
    Empty Results (200):
    []
    
    Error Response (401):
    {
      "error": "Unauthorized"
    }
  EOS

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