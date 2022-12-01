class RelatedContent < ApplicationRecord
  belongs_to :parent, class_name: 'RelatedContent', optional: true
  has_many :replies, class_name: 'RelatedContent', foreign_key: :parent_id, dependent: :destroy
  belongs_to :post
  belongs_to :user
end
