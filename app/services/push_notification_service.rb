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

    options = {title: 'Needpedia', body: message}
    send(registration_ids, options)
  end

  private

  def send(registration_ids, options)
    registration_ids.each do |token|
      message= {
          "message":{
              "token":token,
              "notification":{
                  "body":options[:body],
                  "title":options[:title]
              }
          }
      }

      fcm_service = FcmService.new
      fcm_service.send_notification(message)
    end
  end
end
