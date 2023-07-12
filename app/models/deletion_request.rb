class DeletionRequest < ApplicationRecord
  belongs_to :post_version
  belongs_to :user
  has_rich_text :reason
  validates :post_version, presence: true
  validates :user, presence: true
  validates :reason, presence: true
end
