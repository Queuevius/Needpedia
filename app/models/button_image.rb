class ButtonImage < ApplicationRecord
  has_one_attached :avatar, dependent: :destroy
end
