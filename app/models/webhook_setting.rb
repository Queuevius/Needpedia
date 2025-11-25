class WebhookSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
  
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting ? setting.value : default
  end
  
  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save!
  end
  
  def self.webhook_receiving_enabled?
    get('webhook_receiving_enabled', 'true') == 'true'
  end
  
  def self.webhook_sending_enabled?
    get('webhook_sending_enabled', 'true') == 'true'
  end
  
  def self.webhook_logging_enabled?
    get('webhook_logging_enabled', 'true') == 'true'
  end
end
