class RemoteFollowsController < ApplicationController
  before_action :authenticate_user!
  require 'webfinger'

  def new
    @remote_follow = RemoteFollow.new
    @follows = current_user.outgoing_follows.order(created_at: :desc).limit(10)
  end

  def create
    if current_user.private_key_pem.blank? || current_user.public_key_pem.blank?
      # Generate new RSA keys for the user
      key = OpenSSL::PKey::RSA.new(2048)
      current_user.private_key_pem = key.to_pem
      current_user.public_key_pem = key.public_key.to_pem
      current_user.save!
    end

    # Extract the username and domain from the input
    account = params[:account].to_s.strip

    # Remove @ prefix if present
    account = account.sub(/^@/, '')

    if account.include?('@')
      username, domain = account.split('@', 2)
      begin
        resource = "acct:#{username}@#{domain}"
        webfinger = WebFinger.discover!(resource)

        # Find the ActivityPub actor URL
        target_actor_url = nil
        if webfinger.respond_to?(:links) && webfinger.links.is_a?(Array)
          # Look for both self and profile links
          target_actor_url = webfinger.links.find {|l| l['rel'] == 'self' && l['type'] == 'application/activity+json'}&.dig('href')
          target_actor_url ||= webfinger.links.find {|l| l['rel'] == 'http://webfinger.net/rel/profile-page' && l['type'] == 'application/activity+json'}&.dig('href')
          target_actor_url ||= webfinger.links.find {|l| l['rel'] == 'self'}&.dig('href')
        end
      rescue StandardError => e
        # Check for common error patterns that would indicate user not found
        if e.message.include?('404') || e.message.downcase.include?('not found')
          redirect_to new_remote_follow_path, alert: "User @#{username}@#{domain} was not found on the Fediverse. Please check the username and domain and try again."
          return
        else
          redirect_to new_remote_follow_path, alert: "Unable to find @#{username}@#{domain} on the Fediverse. Please verify the account exists."
          logger.error "WebFinger discovery failed: #{e.class} - #{e.message}"
          return
        end
      rescue => e
        redirect_to new_remote_follow_path, alert: "Something went wrong when looking up @#{username}@#{domain}. Please try again later."
        logger.error "WebFinger discovery failed: #{e.class} - #{e.message}"
        return
      end

      if target_actor_url.present?
        # Send a follow request
        begin
          service = ActivityPub::RequestService.new(current_user)
          service.send_follow_request(target_actor_url)
          redirect_to feed_path, notice: "Follow request sent to @#{username}@#{domain}"
        rescue => e
          redirect_to new_remote_follow_path, alert: "Failed to send follow request: #{e.message}"
        end
      else
        redirect_to new_remote_follow_path, alert: "Could not find ActivityPub endpoint for #{account}"
      end
    else
      redirect_to new_remote_follow_path, alert: "Please enter a valid Fediverse account in the format username@domain.com"
    end
  end
end