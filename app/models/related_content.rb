class RelatedContent < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  has_rich_text :content
  belongs_to :post
  belongs_to :user
end
