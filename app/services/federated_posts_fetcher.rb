# app/services/federated_posts_fetcher.rb
require 'net/http'
require 'uri'
require 'json'

class FederatedPostsFetcher
  MAX_REDIRECTS = 5 # To prevent infinite redirect loops

  def self.fetch_user_posts_from_actor_id(actor_id, redirect_count: 0)
    return [] if redirect_count > MAX_REDIRECTS

    uri = URI.parse(actor_id)
    instance_url = "#{uri.scheme}://#{uri.host}"
    username = uri.path.split('/').last
    user_handle = "@#{username}@#{uri.host}"

    begin
      puts "Attempting to lookup user ID at: #{lookup_url = URI.parse("#{instance_url}/api/v1/accounts/lookup?acct=#{user_handle}")}"
      response = Net::HTTP.get_response(lookup_url)

      case response
      when Net::HTTPSuccess
        user_data = JSON.parse(response.body)
        user_id = user_data['id']
        puts "User ID found: #{user_id}"
        return fetch_user_statuses(instance_url, user_id, user_handle)
      when Net::HTTPRedirection
        location = response['Location']
        puts "Redirected to: #{location}"
        return fetch_user_posts_from_actor_id(location, redirect_count: redirect_count + 1)
      else
        puts "Warning: Could not lookup user #{user_handle} on #{instance_url}: #{response.message}"
        puts "Attempting to fetch posts via outbox..."
        return fetch_posts_from_outbox(actor_id)
      end

    rescue StandardError => e
      puts "An error occurred during lookup for #{actor_id}: #{e.message}"
      []
    end
  end

  def self.fetch_user_statuses(instance_url, user_id, user_handle)
    all_posts = []
    statuses_url = URI.parse("#{instance_url}/api/v1/accounts/#{user_id}/statuses?limit=100")
    next_url = statuses_url

    while next_url
      puts "Fetching statuses from: #{next_url}"
      response = Net::HTTP.get_response(next_url)

      unless response.is_a?(Net::HTTPSuccess)
        puts "Error fetching statuses for #{user_handle} on #{instance_url} from #{next_url}: #{response.message}"
        break
      end

      body = response.body
      begin
        posts_data = JSON.parse(body)
        all_posts.concat(posts_data)
        if response['Link']
          next_link = response['Link'].split(',').find { |link| link.include?('rel="next"') }
          next_url = next_link ? URI.parse(next_link.match(/<(.*?)>/)[1]) : nil
        else
          next_url = nil
        end
      rescue JSON::ParserError => e
        puts "Error parsing JSON response from #{next_url}: #{e.message}"
        break
      end

      sleep(0.5)
    end
    all_posts
  end

  def self.fetch_posts_from_outbox(actor_id, redirect_count: 0)
    return [] if redirect_count > MAX_REDIRECTS

    outbox_url = URI.parse("#{actor_id}/outbox?limit=100")
    puts "Attempting to fetch from outbox: #{outbox_url}"
    response = Net::HTTP.get_response(outbox_url)

    case response
    when Net::HTTPSuccess
      body = response.body
      begin
        posts_data = JSON.parse(body)
        all_posts = []
        if posts_data.is_a?(Hash) && posts_data['items'].present?
          all_posts.concat(posts_data['items'])
          next_link = posts_data['next']
          next_url = next_link ? URI.parse(next_link) : nil
          while next_url
            puts "Fetching next page from outbox: #{next_url}"
            response = Net::HTTP.get_response(next_url)
            break unless response.is_a?(Net::HTTPSuccess)
            body = response.body
            page_data = JSON.parse(body)
            all_posts.concat(page_data['items'])
            next_link = page_data['next']
            next_url = next_link ? URI.parse(next_link) : nil
            sleep(0.5)
          end
        elsif posts_data.is_a?(Array)
          all_posts = posts_data
          # May need to handle pagination differently if it's just an array
          puts "Warning: Outbox returned a simple array - pagination might not be fully handled."
        else
          puts "Warning: Unexpected outbox response format."
        end
        all_posts
      rescue JSON::ParserError => e
        puts "Error parsing JSON from outbox: #{e.message}"
        []
      end
    when Net::HTTPRedirection
      location = response['Location']
      puts "Outbox redirected to: #{location}"
      return fetch_posts_from_outbox(location, redirect_count: redirect_count + 1)
    else
      puts "Error fetching outbox for #{actor_id}: #{response.message}"
      []
    end
  rescue StandardError => e
    puts "An error occurred while fetching outbox for #{actor_id}: #{e.message}"
    []
  end
end