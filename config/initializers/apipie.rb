Apipie.configure do |config|
  config.app_name                = "Needpedia"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apipie"
  config.translate               = false
  config.validate                = false
  config.default_version         = "v1"
  # Scan all controllers so docs include API v1, v2, and webhooks
  config.api_controllers_matcher = Rails.root.join("app","controllers","**","*.rb")
  config.app_info["v1"] = "API documentation for Needpedia."
end
