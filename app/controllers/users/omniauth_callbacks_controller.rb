module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Skip CSRF protection for callbacks
    protect_from_forgery except: [:google_oauth2, :facebook, :twitter, :github]
    skip_before_action :verify_authenticity_token, only: [:google_oauth2, :failure]

    before_action :set_service, except: [:google_oauth2, :failure]
    before_action :set_user, except: [:google_oauth2, :failure]

    attr_reader :service, :user

    def facebook
      handle_auth "Facebook"
    end

    def twitter
      handle_auth "Twitter"
    end

    def github
      handle_auth "Github"
    end

    def google_oauth2
      Rails.logger.info "Google OAuth2 callback received"
      
      begin
        auth = request.env["omniauth.auth"]
        Rails.logger.info "Auth data received: #{auth.to_json}"
        
        @user = User.where(email: auth.info.email).first_or_initialize do |user|
          user.email = auth.info.email
          # Generate a complex password that meets requirements
          user.password = generate_secure_password
          user.provider = auth.provider
          user.uid = auth.uid
          user.name = auth.info.name
          # Skip confirmation for Google OAuth users
          user.skip_confirmation!
          user.confirm if user.respond_to?(:confirm)
        end

        if @user.persisted? || @user.save
          # Ensure existing users are also confirmed
          unless @user.confirmed?
            @user.skip_confirmation!
            @user.confirm
            @user.save
          end
          
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
        else
          session["devise.google_data"] = auth.except(:extra)
          redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
        end
      rescue StandardError => e
        Rails.logger.error "Google OAuth2 Error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to new_user_session_path, alert: "Authentication failed: #{e.message}"
      end
    end

    def failure
      Rails.logger.error "OAuth failure: #{failure_message}"
      redirect_to root_path, alert: "Authentication failed: #{failure_message}"
    end

    private

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

    def auth
      request.env['omniauth.auth']
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
        # 5. User is logged out and they login to a new account which doesn't match their old one
        flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
        redirect_to new_user_session_path
      else
        @user = create_user
      end
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
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
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
