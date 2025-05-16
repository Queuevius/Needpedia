module ActivityPub
  class FederatedTimelineService
    require 'rest-client'
    require 'kaminari'
    
    # List of popular Fediverse instances to include in global search
    POPULAR_INSTANCES = [
      "mastodon.social",
      "mastodon.online",
      "pixelfed.social",
      "fosstodon.org",
      "mas.to",
      "hachyderm.io",
      "mstdn.social"
    ]
    
    def initialize(user)
      @user = user
    end

    # Fetch posts directly from remote ActivityPub servers without storing locally
    def fetch_posts(page: 1, per_page: 10, search_query: nil, global_search: false, platforms: [])
      # Collect all posts from remote servers
      all_posts = []
      
      if global_search && search_query.present?
        # When doing a global search, we'll check known popular instances
        all_posts = search_global_fediverse(search_query, platforms)
      else
        # Get all accepted follows for the current user - standard approach
        remote_follows = @user.remote_follows.where(status: 'accepted')
        
        remote_follows.each do |remote_follow|
          begin
            # Get the actor URL (who we're following)
            actor_url = remote_follow.actor_id
            
            # Fetch the actor document to get the outbox URL
            actor_doc = fetch_actor(actor_url)
            
            # Get the outbox URL from the actor document
            outbox_url = actor_doc["outbox"]
            
            if outbox_url.present?
              # Fetch posts from the outbox
              outbox_posts = fetch_outbox_posts(outbox_url)
              
              # Add the posts to our collection
              all_posts.concat(outbox_posts)
            end
          rescue => e
            # Continue to the next follow, don't let one error stop the whole process
          end
        end
      end
      
      # Filter posts by search query if provided
      if search_query.present?
        search_terms = search_query.downcase.split(/\s+/)
        all_posts = all_posts.select do |post|
          content = post[:content].to_s.downcase
          
          # Check for hashtags specifically
          hashtags_match = search_terms.any? do |term|
            if term.start_with?('#')
              # Remove the # and look for the hashtag in content
              hashtag = term[1..]
              # Match the hashtag pattern in the content
              content.include?("##{hashtag}") || 
              content.match(/\##{Regexp.escape(hashtag)}\b/i)
            else
              false
            end
          end
          
          # Check for normal search terms
          terms_match = search_terms.any? do |term|
            # Skip hashtag terms when doing general content search
            !term.start_with?('#') && content.include?(term)
          end
          
          # Match if any hashtag matches or any term matches
          hashtags_match || terms_match || (search_query.start_with?('@') && post[:federated_author].downcase.include?(search_query[1..].downcase))
        end
      end
      
      # Sort all posts by published date descending
      all_posts.sort_by! { |post| post[:published] }.reverse!
      
      # Paginate the results
      # Using Kaminari's paginate_array to handle pagination on the array
      paginated_posts = Kaminari.paginate_array(all_posts).page(page).per(per_page)
      
      # Return the paginated collection
      paginated_posts
    end
    
    # Search the global Fediverse using known instances
    def search_global_fediverse(search_query, platforms = [])
      all_posts = []
      
      # First search external Fediverse search APIs if a hashtag
      if search_query.start_with?('#')
        hashtag = search_query[1..]
        all_posts.concat(search_hashtag_apis(hashtag, platforms))
      end
      
      # Filter instances based on selected platforms
      instances_to_search = []
      
      if platforms.include?('mastodon')
        # Add mastodon instances
        instances_to_search.concat(POPULAR_INSTANCES.select { |i| i.include?('mastodon') })
      end
      
      if platforms.include?('lemmy')
        # Add lemmy instances
        instances_to_search << "lemmy.ml"
      end
      
      if platforms.include?('reddit')
        # Reddit requires special handling through their API
        reddit_posts = search_reddit(search_query)
        all_posts.concat(reddit_posts)
      end
      
      if platforms.include?('bluesky')
        # Bluesky requires special handling through their API
        bluesky_posts = search_bluesky(search_query)
        all_posts.concat(bluesky_posts)
      end
      
      # For peer instances, include user's connected instances
      if platforms.include?('peer')
        instance_domains = @user.remote_follows.map do |follow|
          uri = URI.parse(follow.actor_id)
          uri.host
        end.compact.uniq - POPULAR_INSTANCES
        
        instances_to_search.concat(instance_domains)
      end
      
      # Then try each instance in our filtered list
      instances_to_search.each do |instance|
        begin
          platform_type = determine_platform_type(instance)
          posts = search_instance(instance, search_query, platform_type)
          all_posts.concat(posts)
        rescue => e
          # Skip instances that fail
        end
      end
      
      all_posts
    end
    
    # Determine the platform type from an instance domain
    def determine_platform_type(instance)
      if instance.include?('mastodon')
        'mastodon'
      elsif instance.include?('lemmy')
        'lemmy'
      elsif instance.include?('reddit')
        'reddit'
      elsif instance.include?('bsky')
        'bluesky'
      else
        'peer'
      end
    end
    
    def search_instance(instance, search_query, platform_type = nil)
      posts = []
      
      begin
        # First try to search using the instance's search endpoint if it has nodeinfo
        node_info_url = "https://#{instance}/.well-known/nodeinfo"
        node_info_response = RestClient.get(node_info_url, { timeout: 5 })
        
        if node_info_response.code == 200
          # Found nodeinfo, now get links to search API
          node_info = JSON.parse(node_info_response.body)
          
          # If it's a Mastodon server, try its API
          if instance.include?('mastodon')
            search_url = "https://#{instance}/api/v2/search"
            search_response = RestClient.get("#{search_url}?q=#{CGI.escape(search_query)}&type=statuses&resolve=true", 
                                            { timeout: 5 })
            
            if search_response.code == 200
              results = JSON.parse(search_response.body)
              if results['statuses'].present?
                results['statuses'].each do |status|
                  # Convert Mastodon API format to our standard format
                  post = {
                    id: status['id'],
                    content: status['content'],
                    author: status['account']['url'],
                    federated_author: status['account']['username'],
                    published: Time.parse(status['created_at']).iso8601,
                    url: status['url'],
                    platform: platform_type || determine_platform_type(instance),
                    hashtags: status['tags'].map { |t| t['name'] },
                    image_url: extract_mastodon_image(status)
                  }
                  posts << post
                end
              end
            end
          end
        end
      rescue => e
        # Fall back to trying to get popular public posts
        begin
          # Try to get public timeline
          public_url = "https://#{instance}/api/v1/timelines/public"
          public_response = RestClient.get(public_url, { timeout: 5 })
          
          if public_response.code == 200
            results = JSON.parse(public_response.body)
            results.each do |status|
              # Filter by search terms
              content = status['content'].to_s.downcase
              if content.include?(search_query.downcase) || 
                 (search_query.start_with?('#') && status['tags'].any? { |t| t['name'].downcase == search_query[1..].downcase }) ||
                 (search_query.start_with?('@') && status['account']['acct'].downcase.include?(search_query[1..].downcase))
                
                post = {
                  id: status['id'],
                  content: status['content'],
                  author: status['account']['url'],
                  federated_author: status['account']['username'],
                  published: Time.parse(status['created_at']).iso8601,
                  url: status['url'],
                  platform: platform_type || determine_platform_type(instance),
                  hashtags: status['tags'].map { |t| t['name'] },
                  image_url: status['media_attachments']&.first&.dig('preview_url') || status['media_attachments']&.first&.dig('url')
                }
                posts << post
              end
            end
          end
        rescue => e
          # Just move on to next instance
        end
      end
      
      posts
    end
    
    def search_hashtag_apis(hashtag, platforms = [])
      posts = []
      
      # Try some common hashtag APIs based on selected platforms
      if platforms.include?('mastodon')
        begin
          # Try Mastodon API format
          hash_url = "https://mastodon.social/api/v1/timelines/tag/#{hashtag}"
          response = RestClient.get(hash_url, { timeout: 5 })
          
          if response.code == 200
            results = JSON.parse(response.body)
            results.each do |status|
              post = {
                id: status['id'],
                content: status['content'],
                author: status['account']['url'],
                federated_author: status['account']['username'],
                published: Time.parse(status['created_at']).iso8601,
                url: status['url'],
                platform: 'mastodon',
                hashtags: status['tags'].map { |t| t['name'] },
                image_url: extract_mastodon_image(status)
              }
              posts << post
            end
          end
        rescue => e
          # Try another API or instance
        end
      end
      
      posts
    end
    
    # Method to search Reddit
    def search_reddit(search_query)
      posts = []
      
      begin
        # Reddit requires OAuth, but for simplicity we'll use their JSON API
        search_url = "https://www.reddit.com/search.json?q=#{CGI.escape(search_query)}&limit=10"
        response = RestClient.get(search_url, { 
          'User-Agent' => 'Needpedia/1.0'
        })
        
        if response.code == 200
          results = JSON.parse(response.body)
          
          if results['data'] && results['data']['children']
            results['data']['children'].each do |child|
              data = child['data']
              
              # Only include actual posts, not comments
              next unless data['title'].present?
              
              post = {
                id: data['id'],
                content: data['title'] + (data['selftext'].present? ? "\n\n" + data['selftext'] : ""),
                author: "https://www.reddit.com/user/#{data['author']}",
                federated_author: data['author'],
                published: Time.at(data['created_utc']).iso8601,
                url: "https://www.reddit.com#{data['permalink']}",
                platform: 'reddit',
                hashtags: [],
                image_url: extract_reddit_image(data)
              }
              
              posts << post
            end
          end
        end
      rescue => e
        # Just return empty array on failure
      end
      
      posts
    end
    
    # Method to search Bluesky
    def search_bluesky(search_query)
      posts = []
      
      # For now, just return a placeholder/mock since Bluesky API requires authentication
      # This would need to be implemented with proper API access
      
      posts
    end
    
    private
    
    def fetch_actor(actor_url)
      response = RestClient.get(actor_url, { 
        'Accept' => 'application/activity+json',
        'User-Agent' => 'NeedpediaBot/1.0'
      })
      
      if response.code == 200
        JSON.parse(response.body)
      else
        raise "Failed to fetch actor document: #{response.code}"
      end
    end
    
    def fetch_outbox_posts(outbox_url)
      # Fetch the outbox
      response = RestClient.get(outbox_url, { 
        'Accept' => 'application/activity+json',
        'User-Agent' => 'NeedpediaBot/1.0'
      })
      
      if response.code == 200
        outbox_data = JSON.parse(response.body)
        
        # Handle different outbox structures (OrderedCollection, etc.)
        items = []
        
        if outbox_data["type"] == "OrderedCollection" || outbox_data["type"] == "Collection"
          if outbox_data["orderedItems"].present?
            # Some servers include items directly
            items = outbox_data["orderedItems"]
          elsif outbox_data["first"].present?
            # Some servers provide a URL to the first page
            first_page_url = outbox_data["first"]
            if first_page_url.is_a?(String)
              first_page_response = RestClient.get(first_page_url, { 
                'Accept' => 'application/activity+json',
                'User-Agent' => 'NeedpediaBot/1.0'
              })
              
              if first_page_response.code == 200
                first_page_data = JSON.parse(first_page_response.body)
                if first_page_data["orderedItems"].present?
                  items = first_page_data["orderedItems"]
                end
              end
            elsif first_page_url.is_a?(Hash) && first_page_url["orderedItems"].present?
              items = first_page_url["orderedItems"]
            end
          end
        end
        
        # Process and extract actual posts (Notes)
        posts = []
        
        items.each do |item|
          # Handle both Create activities and direct Note objects
          if item["type"] == "Create" && item["object"].present?
            object = item["object"]
            
            # If object is a URL, fetch it
            if object.is_a?(String)
              begin
                object_response = RestClient.get(object, { 
                  'Accept' => 'application/activity+json',
                  'User-Agent' => 'NeedpediaBot/1.0'
                })
                
                if object_response.code == 200
                  object = JSON.parse(object_response.body)
                end
              rescue => e
                next
              end
            end
            
            # Only include Note objects
            if object["type"] == "Note"
              post = {
                id: object["id"],
                content: object["content"],
                author: item["actor"],
                federated_author: extract_username_from_url(item["actor"]),
                published: Time.parse(object["published"] || item["published"]).iso8601,
                url: object["url"] || object["id"],
                hashtags: extract_hashtags(object["content"]),
                image_url: object["media_attachments"]&.first&.dig('preview_url') || object["media_attachments"]&.first&.dig('url')
              }
              
              posts << post
            end
          elsif item["type"] == "Note"
            # Direct Note object
            post = {
              id: item["id"],
              content: item["content"],
              author: item["attributedTo"],
              federated_author: extract_username_from_url(item["attributedTo"]),
              published: Time.parse(item["published"]).iso8601,
              url: item["url"] || item["id"],
              hashtags: extract_hashtags(item["content"]),
              image_url: item["media_attachments"]&.first&.dig('preview_url') || item["media_attachments"]&.first&.dig('url')
            }
            
            posts << post
          end
        end
        
        return posts
      else
        raise "Failed to fetch outbox: #{response.code}"
      end
    end
    
    def extract_username_from_url(url)
      if url.present?
        # Extract the username from the URL
        # E.g., https://mastodon.social/users/username -> username
        url.split('/').last
      else
        "unknown"
      end
    end
    
    def extract_hashtags(content)
      return [] unless content.present?
      
      # Extract hashtags from HTML content
      # This regex looks for hashtags in the content
      content.scan(/#(\w+)/).flatten.uniq
    end
    
    def extract_reddit_image(data)
      # Reddit provides image URLs in different formats depending on the post type
      if data['thumbnail'] && data['thumbnail'].match?(/^https?:\/\//)
        # Use thumbnail if it's an actual URL and not "self" or "default"
        data['thumbnail']
      elsif data['preview'] && data['preview']['images'] && data['preview']['images'][0]['source']['url']
        # Use the preview image source URL if available
        CGI.unescapeHTML(data['preview']['images'][0]['source']['url'])
      elsif data['url'] && data['url'].match?(/\.(jpg|jpeg|png|gif)$/i)
        # If the URL is a direct link to an image
        data['url']
      elsif data['url'] && data['url'].include?('imgur.com') && !data['url'].include?('/a/')
        # Handle Imgur links by appending .jpg if it's not an album
        data['url'] + '.jpg' unless data['url'].match?(/\.(jpg|jpeg|png|gif)$/i)
      else
        # No suitable image found
        nil
      end
    end
    
    def extract_mastodon_image(status)
      # Extract image URL from Mastodon status
      if status['media_attachments'].present? && status['media_attachments'].first.present?
        # Try preview_url first, then fallback to url
        status['media_attachments'].first['preview_url'] || status['media_attachments'].first['url']
      elsif status['reblog'].present? && status['reblog']['media_attachments'].present?
        # Try to get image from reblogged post
        reblog = status['reblog']
        if reblog['media_attachments'].first.present?
          reblog['media_attachments'].first['preview_url'] || reblog['media_attachments'].first['url']
        end
      elsif status['card'].present? && status['card']['image'].present?
        # Try to get image from card
        status['card']['image']
      elsif status['account'].present? && status['account']['avatar'].present?
        # Last resort: use the account avatar
        status['account']['avatar']
      else
        nil
      end
    end
  end
end 