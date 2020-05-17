class Gig < ApplicationRecord
  has_rich_text :area_tag
  has_rich_text :body
  has_many_attached :images

  ################################ Relationships ########################
  belongs_to :user, optional: true

  ############################### Validations ###########################
  validates :title, presence: true
  validates :area_tag, presence: true
  validates :body, presence: true
  validates :amount, presence: true

  ############################### Scopes ################################

end
