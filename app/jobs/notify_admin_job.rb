class NotifyAdminJob < ApplicationJob
  queue_as :default

  def perform(ip_address, attempt_count)
    AdminMailer.notify_failed_attempts(ip_address, attempt_count).deliver_now
  end
end
