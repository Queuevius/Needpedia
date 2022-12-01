class InterestedUser < ApplicationRecord
  belongs_to :parent, class_name: 'InterestedUser', optional: true
  has_many :replies, class_name: 'InterestedUser', foreign_key: :parent_id, dependent: :destroy
  belongs_to :post
  belongs_to :user
end
