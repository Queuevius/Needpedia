require 'net/http'
require 'uri'
require 'json'

class FcmService
  FCM_URL = 'https://fcm.googleapis.com/v1/projects/update-needpedia/messages:send'

  def initialize
    @auth_token = fetch_auth_token
  end

  def send_notification(message)
    uri = URI(FCM_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, initheader = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@auth_token}"
    })

    request.body = message.to_json
    response = http.request(request)
    puts "Response #{response.code} #{response.body}"
  end

  private

  # Method to fetch the auth token using Firebase Admin SDK
  def fetch_auth_token
    scope = 'https://www.googleapis.com/auth/cloud-platform'
    creds = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join('config/credentials/google-services.json')),
        scope: scope
    )
    creds.fetch_access_token!['access_token']
  end
end
