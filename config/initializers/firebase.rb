require 'google/cloud/firestore'

credentials_path = Rails.root.join('config/credentials/google-services.json')

begin
  if ENV['DISABLE_FIREBASE'] == 'true'
    Rails.logger.info('[firebase] Initialization disabled via DISABLE_FIREBASE=true') if defined?(Rails)
  elsif File.exist?(credentials_path)
    json = JSON.parse(File.read(credentials_path)) rescue {}
    if json.is_a?(Hash) && json['type']
      FIREBASE_CREDENTIALS = Google::Cloud::Firestore.new(
        project_id: json['project_id'] || 'needpedia-phone-app',
        credentials: credentials_path
      )
    else
      Rails.logger.warn('[firebase] Skipping init: credentials JSON missing required fields') if defined?(Rails)
    end
  else
    Rails.logger.warn("[firebase] Skipping init: credentials file not found at #{credentials_path}") if defined?(Rails)
  end
rescue => e
  Rails.logger.error("[firebase] Initialization failed: #{e.class}: #{e.message}") if defined?(Rails)
end
