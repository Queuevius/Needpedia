require 'google/cloud/firestore'

# Load the Firebase Admin SDK credentials
FIREBASE_CREDENTIALS = Google::Cloud::Firestore.new(
    project_id: "needpedia-phone-app",
    credentials: Rails.root.join('config/credentials/google-services.json')
)
