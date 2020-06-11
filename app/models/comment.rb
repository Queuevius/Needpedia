class Comment < ApplicationRecord

  ################################ Relationships ########################
  # belongs_to :parent_post, class_name: 'Post', foreign_key: :post_id, optional: true
  # belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true
  belongs_to :user
end
