class Rating < ApplicationRecord

  RATINGS = [0, 1, 2, 3, 4, 5, 6].freeze
  LOL_RATING = 6

  belongs_to :user
  belongs_to :rateable, polymorphic: true

  after_create :send_email

  def send_email
    post = rateable
    users = post.users
    users.each do |u|
      next if u.daily_notifications? || !u.track_notifications?

      UserMailer.send_tracking_email(actor: user, receiver: u, post: post).deliver_now
    end
  end
end
