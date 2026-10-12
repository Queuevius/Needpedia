class SignupDraft < ApplicationRecord
  TTL = 15.minutes

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(consumed_at: nil).where('expires_at > ?', Time.current) }

  def self.create_draft!(name:, email:)
    where('expires_at < ?', 1.day.ago).delete_all
    draft = new(name: name, email: email, token: SecureRandom.urlsafe_base64(32),
                expires_at: Time.current + TTL)
    draft.save!
    draft
  end

  def self.find_valid(token)
    return nil if token.blank?

    active.find_by(token: token)
  end

  def consume!
    update!(consumed_at: Time.current) if consumed_at.nil?
  end
end
