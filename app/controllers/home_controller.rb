class HomeController < ApplicationController
  after_action :read_new_comers_message, only: [:index]
  before_action :set_tutorial
  before_action :authenticate_user!, only: [:chatbot]
  def index
    # @q = Post.ransack(params[:q])
    @messages_for_guests = AdminNotification.for_guests
    @messages_for_all = AdminNotification.for_all
    @messages_for_new_comers = AdminNotification.for_new_comers
    @home_video_link = HomeVideo.last
    @home_video_link = @home_video_link.present? ? 'https://www.youtube.com/embed/' + @home_video_link.link.split('?v=')[1] : 'https://www.youtube.com/embed/ac3c5nIkrsc?start=5'
    @how_tos = HowTo.all
    @quick_post = ButtonImage.where(name: "Quick post", page_name: "Home").last
    @archive_post = ButtonImage.where(name: "Archive post", page_name: "Home").last
  end

  def terms
  end
  
  def faq
    @faqs = Faq.all.order('created_at ASC')
  end

  def privacy
  end

  def time_bank
  end

  def chat
    @f = User.ransack(params[:q])
  end

  def chatbot
    @token = current_user.uuid
  end

  private

  def read_new_comers_message
    return unless current_user.present?

    current_user.update(last_login_at: Time.now) if current_user.confirmed_at.present?
  end

  def set_tutorial
    @url = "#{params[:controller]}"
    @url += "/#{params[:action]}" if params[:action] != "index"
    @user_tutorial = current_user.user_tutorials.where(link: @url).last if current_user.present?
  end
end
