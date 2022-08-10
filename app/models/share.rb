class Share < ApplicationRecord

  ################################ Relationships ########################
  belongs_to :shareable, polymorphic: true
  belongs_to :user

  after_create :send_email

  def send_email
    post = shareable
    users = post.users
    users.each do |u|
      next if u.daily_notifications? || !u.track_notifications?

      UserMailer.send_tracking_email(actor: user, receiver: u, post: post).deliver_now
    end
  end

end
