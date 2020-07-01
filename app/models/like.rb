class Like < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :likeable, polymorphic: true
  belongs_to :user

end
