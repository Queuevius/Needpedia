class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :read_notification
  before_action :set_tutorial

  def index
    @notifications = current_user.notifications.where.not(notifiable_type: "Group").order(created_at: :desc)
  end

  private

  def read_notification
    notifications = current_user.notifications.unread
    notifications.update_all read_at: Time.now
  end

  def set_tutorial
    @url = "#{params[:controller]}"
    @user_tutorial = current_user.user_tutorials.where(link: @url).last if current_user.present?
  end
end
