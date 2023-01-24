class Deletion < ApplicationRecord
  belongs_to :deletable, polymorphic: true
  belongs_to :user
end
