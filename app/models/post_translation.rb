class PostTranslation < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  belongs_to :post_version, optional: true

  validates :language, presence: true
  validates :content, presence: true

  scope :for_post, ->(post) { where(post: post) }
  scope :for_language, ->(lang) { where(language: lang) }

  def stale?
    return false if post_version_id.nil?
    post_version_id != post.post_versions.where(active: true).pluck(:id).first
  end
end