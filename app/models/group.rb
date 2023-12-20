class Group < ApplicationRecord
  belongs_to :user
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_one_attached :logo, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :flags, as: :flagable, dependent: :destroy


  def invite_user(user_to_invite)
    return if members.include?(user_to_invite) || requests.exists?(user_id: user_to_invite.id)

    requests.create(user: user_to_invite)
  end
end
