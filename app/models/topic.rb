class Topic < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :post_tokens, dependent: :destroy
  has_rich_text :body
  has_one :body, class_name: 'ActionText::RichText', as: :record
  belongs_to :parent, class_name: 'Topic', optional: true
  has_many :replies, class_name: 'Topic', foreign_key: :parent_id, dependent: :destroy
end
