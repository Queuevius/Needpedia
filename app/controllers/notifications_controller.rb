class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :read_notification

  def index
    @notifications = current_user.notifications
  end

  private

  def read_notification
    notifications = current_user.notifications.unread
    notifications.update_all read_at: Time.now
  end
end
