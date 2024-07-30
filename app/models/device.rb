class Device < ApplicationRecord
  belongs_to :user
  validates_presence_of :registration_id
end
