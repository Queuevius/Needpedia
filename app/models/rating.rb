class Rating < ApplicationRecord

  RATINGS = [0, 1, 2, 3, 4, 5].freeze

  belongs_to :user
  belongs_to :rateable, polymorphic: true
end
