namespace :emails do
  desc "Send Emails"
  task send_daily_emails: :environment do
    p "starting sending email at #{Time.now}"
    users = User.where(daily_notifications: true).where.not(daily_notification_time: nil)
    users.each do |user|
      p "processing user #{user&.name}"
      if already_send?(user)
        p "skipping user #{user&.name}"
        next
      end

      tracking_posts = user.posts.where(updated_at: 15.minutes.ago..Time.now.utc).uniq if user&.track_notifications? || user&.all_notifications?
      messages = Message.where(receiver_id: user.id, created_at: 15.minutes.ago..Time.now.utc) if user&.message_notifications? || user&.all_notifications?
      p "#{tracking_posts&.count || 0} posts and #{messages&.count || 0} messages updates needs email notification"
      p 'sending email'
      if tracking_posts.present? || messages.present?
        UserMailer.send_daily_email(user, tracking_posts, messages).deliver
      end
      p 'updating user'
      user.update(daily_report_sent_at: Time.now.utc)
    end
    p "finished sending email at #{Time.now}"
  end

  def already_send?(user)
    return if user.daily_report_sent_at.nil?

    user.daily_report_sent_at.to_i < 15.minutes.ago.to_i
  end
end