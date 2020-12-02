class HomeController < ApplicationController
  def index
    # @q = Post.ransack(params[:q])
    @messages_for_guests = AdminNotification.for_guests
    @messages_for_all = AdminNotification.for_all
    @messages_for_new_comers = AdminNotification.for_new_comers
    @home_video_link = HomeVideo.last
    @home_video_link = @home_video_link.present? ? 'https://www.youtube.com/embed/' + @home_video_link.link.split('?v=')[1] : 'https://www.youtube.com/embed/ac3c5nIkrsc?start=5'
  end

  def terms
  end

  def privacy
  end

  def time_bank
  end

  def chat
    @f = User.ransack(params[:q])
  end
end
