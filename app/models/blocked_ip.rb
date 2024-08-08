class BlockedIp < ApplicationRecord
  validates :ip, presence: true, uniqueness: true

  after_destroy :remove_login_attempts

  private


  def remove_login_attempts
    LoginAttempt.where(ip_address: ip, success: false )&.destroy_all
  end
end
