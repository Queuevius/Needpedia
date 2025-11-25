class WebhookConfiguration < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :valid_until, ->(time) { where("validate_until > ?", time) }
  scope :valid_now, -> { valid_until(Time.current) }
end
