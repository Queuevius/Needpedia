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
      
      last_part = name.split('_').last
      user = User.find(last_part)
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
  end
end
