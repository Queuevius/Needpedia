class Objective < ApplicationRecord
  belongs_to :parent, class_name: 'Objective', optional: true
  has_many :replies, class_name: 'Objective', foreign_key: :parent_id, dependent: :destroy
  belongs_to :post
  belongs_to :user
end
