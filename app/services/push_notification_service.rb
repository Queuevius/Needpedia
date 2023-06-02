class PushNotificationService
  def initialize(user, notifications_count: 0, messages_count: 0)
    @user = user
    @notifications_count = notifications_count
    @messages_count = messages_count
  end

  attr_accessor :notifications_count, :user, :messages_count

  def send_push_notification
    registration_ids = user.devices.pluck(:registration_id).uniq
    message = case
              when notifications_count.zero? && messages_count.positive?
                "You have #{messages_count} new messages"
              when notifications_count.positive? && messages_count.zero?
                "You have #{notifications_count} notifications about posts"
              else
                "You have #{notifications_count} notifications about posts and #{messages_count} new messages"
              end

    options = {notification: {title: 'Daily Notification', body: message}}
    send(registration_ids, options)
  end

  private

  def send(registration_ids, options)
    fcm = FCM.new(ENV['FCM_API_KEY'])
    registration_ids.each_slice(20) do |registration_ids_slice|
      response = fcm.send_notification(registration_ids_slice, options)
      puts response
    end
  end
end
