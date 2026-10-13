class WelcomeMenu < ApplicationRecord
  has_one_attached :bg_image

  DEFAULT_CONTENT = <<~HTML.freeze
    <p>Here are some places to start — no AI required:</p>
    <ul>
      <li><a href="/how_tos/index">How-to guides</a></li>
      <li><a href="/about_us">About Needpedia</a></li>
      <li><a href="/careers">Volunteer with us</a></li>
    </ul>
  HTML

  ONBOARDING_DEFAULT_TEXT = 'Needpedia is a place for people to share ideas and collaborate but to make that as easy and effective as possible we offer a range of tools, including some which leverage open source AI. They\'re totally optional, and we respect your decision either way, so first we just want to ask, which experience you\'d prefer:'.freeze

  ALLOWED_IMAGE_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze

  validate :bg_image_content_type
  before_save :normalize_onboarding_text

  def self.instance
    order(:id).first || begin
      create!(content: DEFAULT_CONTENT)
    rescue ActiveRecord::ActiveRecordError
      new(content: DEFAULT_CONTENT)
    end
  end

  def aspect_ratio
    if bg_image.attached?
      metadata = bg_image.blob&.metadata || {}
      width = metadata['width'].to_i
      height = metadata['height'].to_i
      return "#{width} / #{height}" if width.positive? && height.positive?
    end
    '1024 / 724'
  end

  def content_or_default
    content.presence || DEFAULT_CONTENT
  end

  def onboarding_text_or_default
    onboarding_text.presence || ONBOARDING_DEFAULT_TEXT
  end

  private

  def normalize_onboarding_text
    self.onboarding_text = nil if onboarding_text.blank?
  end

  def bg_image_content_type
    return unless bg_image.attached?
    return if ALLOWED_IMAGE_TYPES.include?(bg_image.content_type)

    errors.add(:bg_image, 'must be a PNG, JPEG, GIF, or WebP image')
  end
end
