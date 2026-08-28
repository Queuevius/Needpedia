class PostTransformation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :guest, optional: true
  belongs_to :post
  belongs_to :post_version, optional: true

  validates :content_body, presence: true
  validates :user, presence: true, if: -> { guest.nil? }
  validates :guest, presence: true, if: -> { user.nil? }
  validate :exactly_one_owner

  scope :for_user, ->(user) { where(user: user) }
  scope :for_guest, ->(guest) { where(guest: guest) }
  scope :for_post, ->(post) { where(post: post) }

  def stale?
    return false if post_version_id.nil?
    post_version_id != post.post_versions.where(active: true).pluck(:id).first
  end

  private

  def exactly_one_owner
    if user.present? && guest.present?
      errors.add(:base, "Exactly one of user or guest must be present, not both")
    elsif user.nil? && guest.nil?
      errors.add(:base, "Either user or guest must be present")
    end
  end
end
