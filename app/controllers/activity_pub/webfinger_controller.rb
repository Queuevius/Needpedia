module ActivityPub
  class WebfingerController < ActionController::Base
    require 'webfinger'
    require 'http_signatures'
    
    def show
      resource = params[:resource]

      # Extract name from the resource (e.g., "acct:name@domain" or "name@domain")
      if resource.start_with?('acct:')
        name_and_domain = resource.split('acct:').last
      else
        name_and_domain = resource
      end
      
      # Split into name and domain parts
      name_parts = name_and_domain.split('@')
      name = name_parts.first
      
      # Normalize the name (replace underscores with spaces)
      normalized_name = name.gsub('_', ' ').strip

      # Try different ways to find the user
      user = find_user_by_various_criteria(normalized_name, name)

      # Return 404 if user is not found
      unless user
        head :not_found
        return
      end

      # Use the user's method to get a Mastodon-compatible username
      mastodon_compatible_username = user.mastodon_compatible_username
      
      # Build the Webfinger response
      response = {
        subject: "acct:#{mastodon_compatible_username}@#{Rails.application.config.x.domain}",
        links: [
          {
            rel: "self",
            type: "application/activity+json",
            href: activity_pub_actor_url(user, host: Rails.application.config.x.domain, protocol: 'https')
          },
          {
            rel: "http://webfinger.net/rel/profile-page",
            type: "text/html",
            href: "https://#{Rails.application.config.x.domain}/profile/#{user.id}"
          }
        ]
      }
      
      render json: response
    end
    
    private
    
    def find_user_by_various_criteria(normalized_name, original_name)
      # Try various ways to find the user
      user = User.find_by("CONCAT(first_name, ' ', last_name) = ?", normalized_name)
      return user if user
      
      # Try by email
      user = User.find_by("email LIKE ?", "#{original_name}%")
      return user if user
      
      # Try by first name only
      user = User.find_by("first_name = ?", normalized_name)
      return user if user
      
      # Try by first and last name separately
      name_parts = normalized_name.split(' ')
      if name_parts.size >= 2
        first_name = name_parts.first
        last_name = name_parts.last
        user = User.find_by(first_name: first_name, last_name: last_name)
        return user if user
      end
      
      if original_name.to_i > 0
        user = User.find_by(id: original_name.to_i)
        return user if user
      end
    end
  end
end
