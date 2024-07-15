class PushNotificationService
  def initialize(user, notifications_count, messages_count)
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

    options = {title: 'Daily Notification', body: message}
    send(registration_ids, options)
  end

  private



  def send(registration_ids, options)
    fcm = FCM.new(ENV['FCM_API_KEY'], Rails.root.join('config', 'credentials', 'firebase_service.json'), 'needpedia-phone-app')
    message = {
      notification: {
        title: options[:title],
        body: options[:body],
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            category: "#{Time.zone.now.to_i}"
          }
        }
      }
    }

    registration_ids.each do |token|
      message[:token] = token
      response = fcm.send_v1(message)
      puts response
    end
  end
end
