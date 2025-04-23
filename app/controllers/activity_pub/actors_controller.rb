module ActivityPub
  class ActorsController < ActionController::Base
    require 'webfinger'
    require 'http_signatures'
    require 'rest-client'
    
    # Protect from forgery for all non-inbox actions
    protect_from_forgery with: :exception, except: [:inbox]
    
    def show
      user = User.find(params[:id])
      
      # Get the Mastodon-compatible username from the user
      mastodon_compatible_username = user.mastodon_compatible_username

      # Correctly formatted Actor object according to ActivityPub spec
      actor = {
        "@context": [
          "https://www.w3.org/ns/activitystreams",
          "https://w3id.org/security/v1"
        ],
        "id": activity_pub_actor_url(user, protocol: 'https'),
        "type": "Person",
        "preferredUsername": mastodon_compatible_username,
        "name": "#{user.first_name} #{user.last_name}".strip || user.name || "User #{user.id}",
        "summary": user.about.present? ? extract_plain_text(user.about.body.to_s) : "",
        "inbox": inbox_activity_pub_actor_url(user, protocol: 'https'),
        "outbox": outbox_activity_pub_actor_url(user, protocol: 'https'),
        "followers": followers_activity_pub_actor_url(user, protocol: 'https'),
        "following": following_activity_pub_actor_url(user, protocol: 'https'),
        "publicKey": {
          "id": "#{activity_pub_actor_url(user, protocol: 'https')}#main-key",
          "owner": activity_pub_actor_url(user, protocol: 'https'),
          "publicKeyPem": user.public_key_pem
        }
      }
      
      # Return the actor as JSON with correct content type
      render json: actor, content_type: 'application/activity+json'
    end

    def public_key
      user = User.find(params[:id])
      
      key_data = {
        "@context": "https://w3id.org/security/v1",
        "id": "#{activity_pub_actor_url(user, protocol: 'https')}#main-key",
        "owner": activity_pub_actor_url(user, protocol: 'https'),
        "publicKeyPem": user.public_key_pem
      }
      
      render json: key_data, content_type: 'application/activity+json'
    end

    def inbox
      verify_signature!
      process_activity(@json_data)
      head :accepted
    end

    def outbox
      user = User.find(params[:id])
      posts = user.posts.order(created_at: :desc)

      render json: {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": outbox_activity_pub_actor_url(user, protocol: 'https'),
        "type": "OrderedCollection",
        "totalItems": posts.count,
        "orderedItems": posts.map { |post| serialize_post(post) }
      }, content_type: 'application/activity+json'
    end

    def followers
      user = User.find(params[:id])
      followers = user.remote_follows.where(status: RemoteFollow::ACCEPTED)
      
      render json: {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": followers_activity_pub_actor_url(user, protocol: 'https'),
        "type": "Collection",
        "totalItems": followers.count,
        "items": followers.map { |follow| follow.follower_url }
      }, content_type: 'application/activity+json'
    end
    
    def following
      user = User.find(params[:id])
      following = user.outgoing_follows.where(status: RemoteFollow::ACCEPTED)
      
      render json: {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": following_activity_pub_actor_url(user, protocol: 'https'),
        "type": "Collection",
        "totalItems": following.count,
        "items": following.map { |follow| follow.target_url || follow.actor_id }
      }, content_type: 'application/activity+json'
    end

    def handle_accept

      follow_object = @json_data['object']
      if follow_object && follow_object['type'] == 'Follow'
        actor_url = @json_data['actor']
        remote_follow = RemoteFollow.find_by(target_url: actor_url, status: RemoteFollow::PENDING)

        if remote_follow
          remote_follow.update(status: RemoteFollow::ACCEPTED)
        else
        end
      end

      head :accepted
    end

    def process_activity(activity)
      case activity['type']
      when 'Follow'
        handle_follow(activity)
      when 'Create'
        handle_create(activity)
      when 'Accept'
        handle_accept(activity)
      end
    end

    def handle_follow(activity)
      
      begin
        # Extract the target user from the activity object
        target_url = activity['object']
        unless target_url.present?
          return
        end
        
        # Extract the user ID from the target URL
        # The URL format is typically: https://domain.com/activity_pub/actors/123
        # We need to extract the ID (123) from this URL
        target_id = target_url.split('/').last
        
        # Find the target user
        user = User.find(target_id)
        
        # Extract follower information
        follower_url = activity['actor']
        unless follower_url.present?
          return
        end
        
        
        # Fetch the follower's actor information
        begin
          follower_response = RestClient.get(follower_url, { 'Accept' => 'application/activity+json' })
          follower_data = JSON.parse(follower_response.body)
          follower_inbox = follower_data['inbox']
          
          unless follower_inbox.present?
            return
          end
          
          # Create or update the follow relationship
          remote_follow = user.remote_follows.find_or_initialize_by(actor_id: follower_url)
          remote_follow.follower_url = follower_url
          remote_follow.follower_inbox = follower_inbox
          remote_follow.status = RemoteFollow::ACCEPTED # Auto-accept for now
          remote_follow.save!
          
          # Send an Accept activity back to the follower
          request_service = ActivityPub::RequestService.new(user)
          if request_service.send_accept_follow(activity)
          else
          end
        rescue RestClient::Exception => e
        rescue => e
        end
      rescue ActiveRecord::RecordNotFound => e
      rescue => e
      ensure
      end
    end

    def handle_create(activity)
      
      # Extract the object from the Create activity
      object = activity['object']
      
      # If object is a URL, fetch it
      if object.is_a?(String)
        begin
          response = RestClient.get(object, { 
            'Accept' => 'application/activity+json',
            'User-Agent' => 'NeedpediaBot/1.0'
          })
          object = JSON.parse(response.body)
        rescue => e
          return head :ok
        end
      end
      
      # Only handle Note objects for now
      unless object['type'] == 'Note'
        return head :ok
      end
      
      # Find the follow relationship
      actor_url = activity['actor']
      remote_follow = RemoteFollow.find_by(actor_id: actor_url)
      
      # Only process posts from accepted follows
      if remote_follow&.accepted?

        # Find all local users who follow this actor
        local_followers = RemoteFollow.joins(:user)
                                    .where(actor_id: actor_url, status: RemoteFollow::ACCEPTED)
                                    .where.not(users: { id: nil })

        if local_followers.any?
          
          # Create a post record for the notification
          post_content = ActionController::Base.helpers.strip_tags(object['content'].to_s).squish
          post = Post.create!(
            content: post_content,
            user: local_followers.first.user, # Associate with the first follower
            post_type: 'social_media',
            federated: true,
            federated_url: object['url'] || object['id']
          )

          # Create notifications for each local follower
          local_followers.each do |follow|
            next unless follow.user # Skip if no associated local user
            
            Notification.post(
              from: follow.user,
              notifiable: post,
              to: follow.user,
              action: Notification::NOTIFICATION_TYPE_ACTIVITYPUB_POST_SHARED,
              post_id: post.id
            )
            
            # Send email notification if user has instant notifications enabled
            if follow.user.track_notifications == Notification::NOTIFICATION_TYPE_INSTANT
              UserMailer.send_tracking_email(
                actor: follow.user,
                receiver: follow.user,
                post: post
              ).deliver_later
            end
          end
        end
      else
      end
      
      head :ok
    end

    def handle_accept(activity)
      
      begin
        # Extract the original Follow activity from the Accept activity
        follow_activity = activity['object']
        unless follow_activity.present? && follow_activity['type'] == 'Follow'
          return
        end
        
        # Extract the target actor URL (who accepted our follow)
        target_actor_url = activity['actor']
        unless target_actor_url.present?
          return
        end
        
        # Find the pending follow request
        remote_follow = RemoteFollow.find_by(actor_id: target_actor_url, status: RemoteFollow::PENDING)
        unless remote_follow.present?
          return
        end
        
        # Update the follow status to accepted
        remote_follow.status = RemoteFollow::ACCEPTED
        remote_follow.save!
        
      rescue => e
      ensure
      end
    end


    private

    def serialize_post(post)
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "#{post.url}/activity",
        "type": "Create",
        "actor": activity_pub_actor_url(post.user, protocol: 'https'),
        "published": post.created_at.iso8601,
        "to": ["https://www.w3.org/ns/activitystreams#Public"],
        "cc": [followers_activity_pub_actor_url(post.user, protocol: 'https')],
        "object": {
          "id": post.url,
          "type": "Note",
          "content": extract_plain_text(post.content.body.to_s),
          "published": post.created_at.iso8601,
          "attributedTo": activity_pub_actor_url(post.user, protocol: 'https'),
          "to": ["https://www.w3.org/ns/activitystreams#Public"],
          "cc": [followers_activity_pub_actor_url(post.user, protocol: 'https')]
        }
      }
    end

    def extract_plain_text(html_content)
      ActionController::Base.helpers.strip_tags(html_content).squish
    end

    def verify_signature!
      signature_header = request.headers['Signature']


      key_id_match = signature_header.match(/keyId="([^"]+)"/)
      key_id = key_id_match ? key_id_match[1] : nil
      
      headers_match = signature_header.match(/headers="([^"]+)"/)
      signed_headers = headers_match ? headers_match[1].split(' ') : []

      actor_url = key_id&.sub(/#main-key$/, '')

      begin
        response = RestClient.get(actor_url, { 'Accept' => 'application/activity+json' })
        actor_doc = JSON.parse(response.body)
        public_key = actor_doc['publicKey']['publicKeyPem']

        unless public_key
          return false
        end

        key_store = { key_id => public_key }
        
        verification_headers = signed_headers.present? ? signed_headers : ['(request-target)', 'host', 'date']
        
        context = HttpSignatures::Context.new(
          keys: key_store,
          algorithm: 'rsa-sha256',
          headers: verification_headers
        )

        # Store the activity JSON for later processing
        @json_data = JSON.parse(request.body.read)


        valid = context.verifier.valid?(request)
        
        true
      rescue => e
        true
      end
    end
  end
end