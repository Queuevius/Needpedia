class Flag < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :flagable, polymorphic: true
  belongs_to :user

end
