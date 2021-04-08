class HowTo < ApplicationRecord
  has_one_attached :question_picture
  has_one_attached :answer_picture
end
