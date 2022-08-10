class SendNotificationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    service = SendNotificationService.new
    service.perform
  end
end
