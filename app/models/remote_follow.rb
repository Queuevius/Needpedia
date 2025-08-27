class RemoteFollow < ApplicationRecord
  belongs_to :user
  
  # Status constants
  PENDING = 'pending'
  ACCEPTED = 'accepted'
  REJECTED = 'rejected'
  
  validates :actor_id, presence: true, uniqueness: { scope: :user_id }
  validates :follower_url, presence: true
  validates :follower_inbox, presence: true
  validates :status, presence: true
  
  scope :accepted, -> { where(status: ACCEPTED) }
  scope :pending, -> { where(status: PENDING) }
  
  def accepted?
    status == ACCEPTED
  end
end
