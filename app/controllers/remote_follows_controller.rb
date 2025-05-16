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
    account = params[:account].strip

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
      rescue => e
        redirect_to new_remote_follow_path, alert: "WebFinger discovery failed: #{e.message}"
        return
      end

      if target_actor_url.present?
        # Send a follow request
        begin
          service = ActivityPub::RequestService.new(current_user)
          service.send_follow_request(target_actor_url)
          redirect_to feed_path, notice: "Follow request sent to #{account}"
        rescue => e
          redirect_to new_remote_follow_path, alert: "Failed to send follow request: #{e.message}"
        end
      else
        redirect_to new_remote_follow_path, alert: "Could not find ActivityPub endpoint for #{account}"
      end
    else
      redirect_to new_remote_follow_path, alert: "Invalid account format. Must be in the format username@domain.com"
    end
  end
end 