class SendNotificationService
  def perform
    p "starting sending email at #{Time.now}"
    users = User.includes(posts: [:likes, :comments, :shares, :flages, :ratings]).where(daily_notifications: true, daily_notification_time: Time.now.utc..Time.now.utc + 10.minutes)
    users.each do |user|
      p "processing user #{user&.name}"
      if already_send?(user)
        p "skipping user as daily notification already sent #{user&.name}"
        next
      end

      posts = []
      if user&.track_notifications? || user&.all_notifications?
        tracking_posts = user.tracking_posts.collect(&:post).flatten.uniq
        tracking_posts.each do |post|
          with_new_likes = post.likes.where(created_at: 24.hours.ago..Time.now.utc)
          with_new_shares = post.shares.where(created_at: 24.hours.ago..Time.now.utc)
          with_new_comments = post.comments.where(created_at: 24.hours.ago..Time.now.utc)
          with_new_flags = post.flags.where(created_at: 24.hours.ago..Time.now.utc)
          with_new_ratings = post.ratings.where(created_at: 24.hours.ago..Time.now.utc)
          posts << post if with_new_likes.any? || with_new_shares.any? || with_new_comments.any? || with_new_flags.any? || with_new_ratings.any?
          # posts << with_new_likes << with_new_shares << with_new_comments << with_new_flags << with_new_ratings
        end
        just_updated = Post.where(id: tracking_posts.pluck(:id), updated_at: 24.hours.ago..Time.now.utc)
        posts << just_updated if just_updated.present?
        posts = posts.uniq.reject(&:blank?)
      end


      # tracking_posts = posts.uniq.reject(&:blank?) if user&.track_notifications? || user&.all_notifications?
      messages = Message.where(receiver_id: user.id, created_at: 24.hours.ago..Time.now.utc) if user&.message_notifications? || user&.all_notifications?
      p "#{posts&.count || 0} posts and #{messages&.count || 0} messages updates needs email notification"
      p 'sending email'
      if posts.present? || messages.present?
        UserMailer.send_daily_email(user, posts, messages).deliver
      end
      p 'updating user'
      user.update(daily_report_sent_at: Time.now.utc)
    end
    p "finished sending email at #{Time.now}"
  end

  private
  def already_send?(user)
    return if user.daily_report_sent_at.nil?

    user.daily_report_sent_at.to_i > 15.minutes.ago.to_i
  end
end