class AiToken < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :guest, optional: true

  validates :user, presence: true, if: -> { guest.nil? }
  validates :guest, presence: true, if: -> { user.nil? }

  before_create :set_default_tokens_count

  private

  def set_default_tokens_count
    if user.present?
      self.tokens_count = ENV['USER_TOKENS_COUNT']&.to_i
    elsif guest.present?
      self.tokens_count = ENV['GUEST_TOKENS_COUNT']&.to_i
    end
  end
end
