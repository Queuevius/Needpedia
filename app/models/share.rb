class Share < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :shareable, polymorphic: true
  belongs_to :user

end
