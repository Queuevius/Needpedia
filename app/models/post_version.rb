class PostVersion < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many :flags, as: :flagable, dependent: :destroy
  has_many :deletion_requests, dependent: :destroy
  has_rich_text :content
  after_destroy :update_post_content

  private

  def update_post_content
    last_version = post.post_versions.last
    if last_version.present?
      post.update(content: last_version.content)
      last_version.update(active: true)
    else
      DeletePostService.new(post.id, post.user.id).delete_post
    end
  end
end
