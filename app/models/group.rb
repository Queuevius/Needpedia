class Group < ApplicationRecord
  belongs_to :user
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_one_attached :logo, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :flags, as: :flagable, dependent: :destroy
  has_rich_text :content
  has_one :content, class_name: 'ActionText::RichText', as: :record
  has_many :post_tokens, dependent: :destroy
  has_many :layers, class_name: 'Group', foreign_key: :group_id, dependent: :destroy
  has_many :child_posts, class_name: 'Group', foreign_key: :group_id, dependent: :destroy
  belongs_to :parent_group, class_name: 'Group', foreign_key: :group_id, optional: true
  GROUP_TYPE_LAYER = 'layer'.freeze
  scope :layer_groups, -> { where(group_type: GROUP_TYPE_LAYER, disabled: false) }


  def invite_user(user_to_invite)
    return if members.include?(user_to_invite) || requests.exists?(user_id: user_to_invite.id)

    requests.create(user: user_to_invite)
  end
end
