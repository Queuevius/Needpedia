class Questionnaire < ApplicationRecord
  has_many :questions, dependent: :destroy

  has_many :user_questionnaires, dependent: :destroy
  has_many :users, through: :user_questionnaires
end
