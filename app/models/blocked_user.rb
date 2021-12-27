class BlockedUser < ApplicationRecord
  belongs_to :user
  belongs_to :block_user, class_name: 'User'
end
