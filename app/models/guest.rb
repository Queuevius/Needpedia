class Guest < ApplicationRecord
  has_many :chat_threads, dependent: :destroy
  has_many :ai_tokens, dependent: :destroy

  validates :uuid, presence: true, uniqueness: true
  validates :fingerprint, presence: true


  before_validation :ensure_uuid
  before_validation :generate_fingerprint
  after_create :create_ai_tokens


  # Scopes for finding matching guests
  scope :matching_identity, ->(ip, fingerprint, user_agent) {
    where("ip = ? OR last_ip = ? OR (fingerprint = ? AND user_agent = ?)",
          ip, ip, fingerprint, user_agent)
  }

  scope :find_by_identifiers, ->(ip) {
    where("ip = ? OR last_ip = ?", ip, ip)
  }

  scope :inactive, ->(days = 30) {
    where('updated_at < ?', days.days.ago)
  }

  def track_ip_change(new_ip)
    return if new_ip == last_ip

    update(
        last_ip: new_ip,
        ip: ip || new_ip # Keep original IP if it exists
    )
  end

  def browser_changed?(new_user_agent)
    user_agent != new_user_agent
  end

  def update_tracking_info(new_ip, new_user_agent)
    track_ip_change(new_ip)

    if browser_changed?(new_user_agent)
      update(user_agent: new_user_agent)
    end
  end

  def probably_same_user?(other_guest)
    return false unless other_guest

    # Check if either IP matches
    ip_match = ip == other_guest.ip ||
        ip == other_guest.last_ip ||
        last_ip == other_guest.ip ||
        last_ip == other_guest.last_ip

    # Check fingerprint match
    fingerprint_match = fingerprint == other_guest.fingerprint

    # Consider them the same user if either condition is true
    ip_match || fingerprint_match
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def generate_fingerprint
    return if fingerprint.present?

    if ip.present? && user_agent.present?
      data = [
          ip,
          user_agent,
          # Browser-specific data
          Time.current.to_date.to_s,  # Use date for more stable matching
      ]
      self.fingerprint = Digest::SHA256.hexdigest(data.join('-'))
    end
  end

  def normalize_ip(ip_address)
    # Remove any IPv6 formatting if present
    ip_address.to_s.gsub(/^::ffff:/, '')
  end

  def create_ai_tokens
    self.ai_tokens.create
  end
end