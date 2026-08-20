class PostTranslation < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :language, presence: true
  validates :content, presence: true

  scope :for_post, ->(post) { where(post: post) }
  scope :for_language, ->(lang) { where(language: lang) }
end