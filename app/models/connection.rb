class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  def validate_unique_following
    following = Connection.find_by(followers_id: self.following_id, following_id: self.followers_id)
    followers = Connection.find_by(followers_id: self.followers_id, following_id: self.following_id)
    return errors.add(:followings, 'This connection already exists.') unless following || followers
  end
end
