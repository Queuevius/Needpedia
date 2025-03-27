module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Skip CSRF protection for callbacks
    protect_from_forgery except: [:google_oauth2, :facebook, :twitter, :github]
    skip_before_action :verify_authenticity_token, only: [:google_oauth2, :facebook, :failure]

    before_action :set_auth, only: [:facebook, :google_oauth2]
    before_action :set_service, except: [:google_oauth2, :facebook, :failure]
    before_action :set_user, except: [:google_oauth2, :facebook, :failure]

    attr_reader :service, :user, :auth

    def facebook
      handle_oauth("Facebook")
    end

    def twitter
      handle_auth "Twitter"
    end

    def github
      handle_auth "Github"
    end

    def google_oauth2
      handle_oauth("Google")
    end

    def failure
      Rails.logger.error "OAuth failure: #{failure_message}"
      redirect_to root_path, alert: "Authentication failed: #{failure_message}"
    end

    private

    def handle_oauth(kind)
      Rails.logger.info "#{kind} OAuth callback received"
      
      begin
        Rails.logger.info "Auth data received: #{auth.to_json}"
        
        # Get or generate email
        email = get_email_from_auth
        
        @user = find_or_initialize_user
        
        if @user.persisted? || @user.save
          # Ensure existing users are also confirmed
          confirm_user if @user.respond_to?(:confirm)
          
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
        else
          Rails.logger.error "Failed to save user: #{@user.errors.full_messages.join(', ')}"
          session["devise.#{auth.provider}_data"] = auth.except(:extra)
          redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
        end
      rescue StandardError => e
        handle_oauth_error(e, kind)
      end
    end

    def handle_auth(kind)
      if service.present?
        service.update(service_attrs)
      else
        user.services.create(service_attrs)
      end

      if user_signed_in?
        flash[:notice] = "Your #{kind} account was connected."
        redirect_to edit_user_registration_path
      else
        sign_in_and_redirect user, event: :authentication
        set_flash_message :notice, :success, kind: kind
      end
    end

    def set_auth
      @auth = request.env['omniauth.auth']
    end

    def get_email_from_auth
      if auth.info.email.blank?
        temp_email = "#{auth.uid}-#{auth.provider}@needpedia.org"
        Rails.logger.info "No email provided by #{auth.provider}, using temporary email: #{temp_email}"
        temp_email
      else
        auth.info.email
      end
    end

    def find_or_initialize_user
      User.where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
        user.email = get_email_from_auth
        user.password = generate_secure_password
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.name || "#{auth.info.first_name} #{auth.info.last_name}"
        user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
        user.confirm if user.respond_to?(:confirm)
      end
    end

    def confirm_user
      unless @user.confirmed?
        @user.skip_confirmation! if @user.respond_to?(:skip_confirmation!)
        @user.confirm if @user.respond_to?(:confirm)
        @user.save
      end
    end

    def handle_oauth_error(exception, provider)
      Rails.logger.error "#{provider} OAuth Error: #{exception.class} - #{exception.message}"
      Rails.logger.error exception.backtrace.join("\n")
      redirect_to new_user_session_path, alert: "Authentication failed: #{exception.message}"
    end

    def service_attrs
      expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
      {
          provider: auth.provider,
          uid: auth.uid,
          expires_at: expires_at,
          access_token: auth.credentials.token,
          access_token_secret: auth.credentials.secret,
      }
    end

    def create_user
      User.create(
        email: get_email_from_auth,
        password: generate_secure_password
      )
    end

    def set_service
      @service = Service.where(provider: auth.provider, uid: auth.uid).first
    end

    def set_user
      if user_signed_in?
        @user = current_user
      elsif service.present?
        @user = service.user
      elsif User.where(email: auth.info.email).any?
        flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
        redirect_to new_user_session_path
      else
        @user = create_user
      end
    end

    def generate_secure_password
      special_chars = '!@#$%^&*()_+-=[]{}|;:,.<>?'
      password = ''
      password += ('A'..'Z').to_a.sample # Add 1 uppercase
      password += ('a'..'z').to_a.sample # Add 1 lowercase
      password += ('0'..'9').to_a.sample # Add 1 digit
      password += special_chars.split('').sample # Add 1 special char
      
      # Add more random characters to make it longer (at least 12 chars)
      remaining_length = 8
      chars = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + special_chars.split('')
      remaining_length.times { password += chars.sample }
      
      # Shuffle the password to make it more random
      password.split('').shuffle.join
    end

    def failure_message
      error = request.env["omniauth.error"]
      error_type = request.env["omniauth.error.type"]
      
      if error.nil? && error_type.nil?
        "Unknown error"
      else
        "#{error_type.to_s.humanize} - #{error&.message}"
      end
    end
  end
end
