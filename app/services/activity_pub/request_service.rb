module ActivityPub
  class RequestService
    require 'http_signatures'
    require 'rest-client'
    require 'base64'
    require 'openssl'
    require 'digest'

    # Include Rails URL helpers
    include Rails.application.routes.url_helpers

    def initialize(user)
      @user = user
    end

    def post_to_inbox(inbox_url, activity)
      begin
        # Ensure actor_id is present and get the full actor URL for signing
        actor_url = get_actor_url(@user)

        # Format date properly for HTTP
        date = Time.now.utc.httpdate

        # Parse the inbox URL
        uri = URI.parse(inbox_url)
        request_target = "post #{uri.path}"
        host = uri.host

        # Convert activity to JSON
        json_data = activity.to_json

        # Create digest of the activity
        digest = "SHA-256=#{Digest::SHA256.base64digest(json_data)}"

        # Define headers in the exact order required for signing
        headers = {
            '(request-target)' => request_target,
            'host' => host,
            'date' => date,
            'digest' => digest,
            'content-type' => 'application/activity+json'
        }

        # Define headers for signature in the exact order required
        header_names = ['(request-target)', 'host', 'date', 'digest', 'content-type']

        # Construct the string to sign with exact formatting
        string_to_sign = header_names.map do |header|
          "#{header}: #{headers[header]}"
        end.join("\n")

        # Sign the string
        private_key = OpenSSL::PKey::RSA.new(@user.private_key_pem)
        signature = Base64.strict_encode64(private_key.sign(OpenSSL::Digest.new('SHA256'), string_to_sign))

        # Create key ID using exact format that Mastodon expects
        key_id = "#{actor_url}#main-key"

        # Create signature header with exact formatting
        signature_header = "keyId=\"#{key_id}\",algorithm=\"rsa-sha256\",headers=\"#{header_names.join(' ')}\",signature=\"#{signature}\""

        # Add the signature to headers
        headers['signature'] = signature_header

        # Convert header keys to proper case for HTTP request
        http_headers = {}
        headers.each do |k, v|
          next if k == '(request-target)' # Skip the (request-target) pseudo-header
          # Ensure consistent capitalization for HTTP headers
          http_headers[k.split('-').map(&:capitalize).join('-')] = v
        end

        # Add essential Accept header
        http_headers['Accept'] = 'application/activity+json, application/ld+json'

        # Log the request for debugging purposes
        Rails.logger.info "ActivityPub Request to #{inbox_url} with headers: #{http_headers.inspect}"
        Rails.logger.info "ActivityPub Request body: #{json_data}"

        begin
          # Send request
          response = RestClient.post(inbox_url, json_data, http_headers)
          Rails.logger.info "ActivityPub Response Success: #{response.code}"
          return true
        rescue RestClient::Exception => e
          # Handle response with error code
          Rails.logger.error "ActivityPub Request failed with status #{e.http_code}: #{e.response&.body}"
          # Try to extract the response body for more information
          error_details = begin
            JSON.parse(e.response&.body || "{}")
          rescue
            {"error" => e.message}
          end
          Rails.logger.error "Error details: #{error_details.inspect}"

          # For certain HTTP error codes, we might need to retry or modify the request
          if e.http_code == 401 # Unauthorized
            Rails.logger.error "Authentication failed. Please check your WebFinger configuration and key validity."
          elsif e.http_code == 429 # Too Many Requests
            Rails.logger.error "Rate limited. Consider implementing backoff retry logic."
          end

          raise e
        end
      rescue => e
        Rails.logger.error "ActivityPub Request general error: #{e.message}"
        raise e
      end
    end

    def send_follow_request(target_actor_url)
      begin
        # Normalize target actor URL
        target_actor_url = normalize_actor_url(target_actor_url)

        # Get the actor URL for the user
        actor_url = get_actor_url(@user)

        # Create a unique ID for the Follow activity
        activity_id = "#{actor_url}/follows/#{SecureRandom.uuid}"

        # Create the Follow activity - using exact format expected by Mastodon
        follow_activity = {
            "@context": "https://www.w3.org/ns/activitystreams",
            "id": activity_id,
            "type": "Follow",
            "actor": actor_url,
            "object": target_actor_url
        }

        # Fetch the actor's inbox URL
        begin
          actor_doc = fetch_actor(target_actor_url)

          inbox_url = actor_doc["inbox"]

          if inbox_url.blank?
            Rails.logger.error "No inbox URL found for #{target_actor_url}"
            raise "No inbox URL found for #{target_actor_url}"
          end

          # Post the Follow activity to the inbox
          result = post_to_inbox(inbox_url, follow_activity)

          # Create a RemoteFollow record to track this outgoing follow request
          remote_follow = @user.remote_follows.find_or_initialize_by(actor_id: target_actor_url)
          remote_follow.follower_url = actor_url
          remote_follow.follower_inbox = get_actor_url(@user) + "/inbox"
          remote_follow.target_url = target_actor_url
          remote_follow.status = RemoteFollow::PENDING
          remote_follow.save!

          return result
        rescue => e
          Rails.logger.error "Failed to send follow request to #{target_actor_url}: #{e.message}"
          raise "Failed to send follow request to #{target_actor_url}: #{e.message}"
        end
      rescue => e
        Rails.logger.error "Error sending follow request: #{e.message}"
        raise "Error sending follow request: #{e.message}"
      end
    end

    def send_accept_follow(follow_activity)
      # Get the actor URL for the user
      actor_url = get_actor_url(@user)

      # Create the Accept activity
      # The object should be the original Follow activity, not a nested object
      accept_activity = {
          "@context": "https://www.w3.org/ns/activitystreams",
          "id": "#{actor_url}/accept/#{SecureRandom.uuid}",
          "type": "Accept",
          "actor": actor_url,
          "object": follow_activity
      }

      # Get the follower's actor URL (from Mastodon, this is a string, not an object)
      follower_actor_url = follow_activity["actor"]

      unless follower_actor_url.present?
        Rails.logger.error "No actor URL found in follow activity: #{follow_activity.inspect}"
        return false
      end

      # Fetch the follower's actor information to get the inbox URL
      begin
        follower_data = fetch_actor(follower_actor_url)
        follower_inbox = follower_data["inbox"]

        unless follower_inbox.present?
          Rails.logger.error "No inbox found for follower: #{follower_actor_url}"
          return false
        end

        # Send the Accept activity to the follower's inbox
        post_to_inbox(follower_inbox, accept_activity)
        return true
      rescue => e
        Rails.logger.error "Error sending Accept activity: #{e.message}"
        raise "Error sending Accept activity: #{e.message}"
      end
    end

    def send_create_note(post)
      # Get all followers
      followers = @user.remote_followers

      # Create the Note object
      note = {
          '@context': 'https://www.w3.org/ns/activitystreams',
          'id': post.url,
          'type': 'Note',
          'published': post.created_at.iso8601,
          'attributedTo': get_actor_url(@user),
          'content': ActionController::Base.helpers.strip_tags(post.content.body.to_s).squish,
          'to': ['https://www.w3.org/ns/activitystreams#Public'],
          'cc': [@user.followers_url]
      }

      # Create the Create activity
      create_activity = {
          '@context': 'https://www.w3.org/ns/activitystreams',
          'id': "#{post.url}/activity",
          'type': 'Create',
          'actor': get_actor_url(@user),
          'object': note,
          'published': post.created_at.iso8601,
          'to': ['https://www.w3.org/ns/activitystreams#Public'],
          'cc': [@user.followers_url]
      }

      # Send the Create activity to all followers
      success_count = 0
      error_count = 0

      followers.each do |follower|
        begin
          post_to_inbox(follower.follower_inbox, create_activity)
          success_count += 1
        rescue => e
          Rails.logger.error "Failed to send Create activity to #{follower.follower_inbox}: #{e.message}"
          error_count += 1
        end
      end

      Rails.logger.info "ActivityPub Create Note: Sent to #{success_count} followers, #{error_count} failures"

      # Create notifications for local followers
      local_followers = @user.remote_followers.joins(:user).where.not(users: { id: nil })
      if local_followers.any?
        local_followers.each do |follower|
          next unless follower.user # Skip if no associated local user

          Notification.post(
              from: @user,
              notifiable: post,
              to: follower.user,
              action: Notification::NOTIFICATION_TYPE_ACTIVITYPUB_POST_SHARED,
              post_id: post.id
          )

          # Send email notification if user has instant notifications enabled
          if follower.user.track_notifications == Notification::NOTIFICATION_TYPE_INSTANT
            UserMailer.send_tracking_email(
                actor: @user,
                receiver: follower.user,
                post: post
            ).deliver_later
          end
        end
      end

      return { success: success_count, errors: error_count }
    end

    private

    def verify_ssl_certificate(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # For testing only!

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = 'application/activity+json'
      request['User-Agent'] = 'Mozilla/5.0 (compatible; NeedpediaBot/1.0; +https://needpedia.org)'

      response = http.request(request)

      if response.code.to_i >= 200 && response.code.to_i < 300
        Rails.logger.info "Certificate verification test successful for #{url}"
        return true
      else
        Rails.logger.warn "Certificate verification test failed for #{url} with status #{response.code}"
        return false
      end
    rescue => e
      Rails.logger.error "Certificate verification error for #{url}: #{e.message}"
      return false
    end

    def get_domain
       Rails.application.config.x.domain
    end

    def get_actor_url(user)
      activity_pub_actor_url(user, host: get_domain, protocol: 'https')
    end

    def normalize_actor_url(url)
      url = url.to_s.strip

      if url.include?('@') && !url.start_with?('http')
        parts = url.split('@')
        username = parts[0].gsub(/^@/, '')
        domain = parts[1]

        if domain.end_with?('hachyderm.io')
          return "https://#{domain}/users/#{username}"
        end

        return url
      end

      if !url.start_with?('http://') && !url.start_with?('https://')
        url = "https://#{url}"
      end

      # Handle specific domains with known URL patterns
      uri = URI.parse(url)
      domain = uri.host
      path = uri.path

      if domain
        if path.include?('@')
          username = path.match(/@([^\/]+)/)[1] rescue nil
          if username
            return "https://#{domain}/users/#{username}"
          end
        elsif !path.include?('/users/')
          # If path doesn't have /users/ but has some other path, try to convert
          parts = path.split('/')
          username = parts.last
          if username && !username.empty?
            return "https://#{domain}/users/#{username}"
          end
        end
      end

      # Remove any trailing slashes and .json extensions
      url.chomp('/').sub(/\.json$/, '')
    end


    def fetch_actor(actor_url)
      # Normalize the actor URL first
      actor_url = normalize_actor_url(actor_url)

      Rails.logger.info "Fetching actor information from: #{actor_url}"

      # Create a standard set of headers that most ActivityPub servers will accept
      standard_headers = {
          'Accept' => 'application/activity+json, application/ld+json; profile="https://www.w3.org/ns/activitystreams"',
          'User-Agent' => 'Mozilla/5.0 (compatible; NeedpediaBot/1.0; +https://needpedia.org)'
      }

      # Try direct request first - this is the most standards-compliant approach
      begin
        Rails.logger.info "Trying direct request to #{actor_url}"
        response = RestClient::Request.execute(
            method: :get,
            url: actor_url,
            headers: standard_headers,
            verify_ssl: OpenSSL::SSL::VERIFY_PEER,
            timeout: 10
        )

        if response.code == 200
          return JSON.parse(response.body)
        end
      rescue RestClient::Exception => e
        Rails.logger.warn "Direct request failed with HTTP status #{e.http_code}: #{e.message}"
        Rails.logger.warn "Response body: #{e.response&.body}"
      rescue => e
        Rails.logger.warn "Direct request failed: #{e.class} - #{e.message}"
      end

      # If direct request failed, try with .json extension (common with Mastodon)
      begin
        json_url = "#{actor_url}.json"
        Rails.logger.info "Trying request with .json extension: #{json_url}"
        response = RestClient::Request.execute(
            method: :get,
            url: json_url,
            headers: standard_headers,
            verify_ssl: OpenSSL::SSL::VERIFY_PEER,
            timeout: 10
        )

        if response.code == 200
          return JSON.parse(response.body)
        end
      rescue RestClient::Exception => e
        Rails.logger.warn "JSON extension request failed with HTTP status #{e.http_code}: #{e.message}"
      rescue => e
        Rails.logger.warn "JSON extension request failed: #{e.class} - #{e.message}"
      end

      # If both direct approaches failed, try WebFinger resolution
      begin
        # Extract domain and username for WebFinger
        uri = URI.parse(actor_url)
        domain = uri.host
        username = nil

        # Try to extract username based on common URL patterns
        if uri.path =~ /\/users\/([^\/\.]+)/
          username = $1
        elsif uri.path =~ /\/@([^\/\.]+)/
          username = $1
        else
          # Last part of path as fallback
          parts = uri.path.split('/')
          username = parts.last.split('.').first if parts.any?
        end

        Rails.logger.info "Extracted WebFinger components - Domain: #{domain}, Username: #{username}"

        if username && domain
          # Build WebFinger URL
          webfinger_url = "https://#{domain}/.well-known/webfinger?resource=acct:#{username}@#{domain}"
          Rails.logger.info "Trying WebFinger lookup: #{webfinger_url}"

          webfinger_headers = {
              'Accept' => 'application/json',
              'User-Agent' => 'Mozilla/5.0 (compatible; NeedpediaBot/1.0; +https://needpedia.org)'
          }

          webfinger_response = RestClient::Request.execute(
              method: :get,
              url: webfinger_url,
              headers: webfinger_headers,
              verify_ssl: OpenSSL::SSL::VERIFY_PEER,
              timeout: 10
          )

          if webfinger_response.code == 200
            webfinger_data = JSON.parse(webfinger_response.body)

            # Look for the appropriate link
            links = webfinger_data['links'] || []

            # First try to find self link with activity+json type
            self_link = links.find { |link| link['rel'] == 'self' && link['type'] == 'application/activity+json' }

            # If not found, try with ld+json type
            if !self_link
              self_link = links.find { |link| link['rel'] == 'self' && link['type'] == 'application/ld+json' }
            end

            # If still not found, try any self link
            if !self_link
              self_link = links.find { |link| link['rel'] == 'self' }
            end

            # If found a self link, request the actor data
            if self_link && self_link['href']
              actor_url = self_link['href']
              Rails.logger.info "Found actor URL from WebFinger: #{actor_url}"

              actor_response = RestClient::Request.execute(
                  method: :get,
                  url: actor_url,
                  headers: standard_headers,
                  verify_ssl: OpenSSL::SSL::VERIFY_PEER,
                  timeout: 10
              )

              if actor_response.code == 200
                return JSON.parse(actor_response.body)
              end
            else
              Rails.logger.warn "No suitable self link found in WebFinger response"
            end
          end
        end
      rescue RestClient::Exception => e
        Rails.logger.warn "WebFinger resolution failed with HTTP status #{e.http_code}: #{e.message}"
      rescue => e
        Rails.logger.warn "WebFinger resolution failed: #{e.class} - #{e.message}"
      end

      # If we get here, all methods failed
      raise "Unable to fetch actor information for #{actor_url} after trying all strategies"
    end

  end
end