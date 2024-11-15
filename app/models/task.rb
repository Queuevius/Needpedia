class Task < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_one_attached :image
end
