class PostVersion < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many :flags, as: :flagable, dependent: :destroy
  has_many :deletion_requests, dependent: :destroy
  has_rich_text :content
end
