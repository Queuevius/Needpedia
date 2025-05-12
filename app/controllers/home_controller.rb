class HomeController < ApplicationController
  include OtpVerifiable

  after_action :read_new_comers_message, only: [:index]
  before_action :set_tutorial
  before_action :check_otp, only: [:time_bank]
  before_action :track_guest, only: [:chatbot]
  before_action :authenticate_user!, only: [:fediverse_feed]

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

  def fediverse_feed
    unless current_user
      redirect_to root_path, alert: "You need to sign in to view the Fediverse feed"
      return
    end
    
    # Get search query if provided
    @search_query = params[:search]
    @global_search = params[:global_search] == "1"
    
    # Fetch posts directly from the fediverse without storing locally
    service = ActivityPub::FederatedTimelineService.new(current_user)
    @federated_posts = service.fetch_posts(
      page: params[:page], 
      per_page: 10,
      search_query: @search_query,
      global_search: @global_search
    )
    
    # Set appropriate title
    @title = if @search_query.present?
      if @global_search
        "Global Fediverse Search: #{@search_query}"
      else
        "Following Search: #{@search_query}"
      end
    else
      "Fediverse Feed"
    end
    
    respond_to do |format|
      format.html
      format.js
    end
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
    @token = current_user&.uuid || current_guest.uuid
    @chatbot_url = current_user.present? ? ENV['CHATBOT_URL'] : ENV['GUEST_CHATBOT_URL']
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

  def track_guest
    return if current_user
    return if BlockedIp.exists?(ip: request.remote_ip)

    guest = Guest.find_or_create_by(ip: request.remote_ip) do |new_guest|
      new_guest.uuid = SecureRandom.uuid
      new_guest.fingerprint = SecureRandom.hex(16)

    end
    @current_guest = guest

    # @current_guest = find_or_create_guest
    # track_guest_changes if @current_guest
  end

  def find_or_create_guest
    guest = find_guest_by_cookie || find_guest_by_identity || create_new_guest
    update_guest_cookie(guest) if guest
    guest
  end

  def find_guest_by_cookie
    return nil unless cookies[:guest_uuid]
    Guest.find_by(uuid: cookies[:guest_uuid])
  end

  def find_guest_by_identity
    return nil unless request.remote_ip.present? && request.user_agent.present?

    temp_fingerprint = generate_temp_fingerprint
    Guest.where("ip = ? OR last_ip = ? OR fingerprint = ?",
                request.remote_ip, request.remote_ip, temp_fingerprint)
        .first
  end

  def create_new_guest
    Guest.create(
        ip: request.remote_ip,
        last_ip: request.remote_ip,
        user_agent: request.user_agent
    )
  end

  def track_guest_changes
    return unless @current_guest.last_ip != request.remote_ip ||
        @current_guest.user_agent != request.user_agent

    @current_guest.update(
        last_ip: request.remote_ip,
        user_agent: request.user_agent
    )
  end

  def generate_temp_fingerprint
    data = [
        request.remote_ip,
        request.user_agent,
        request.headers['Accept-Language'],
        Time.current.to_date.to_s
    ].compact

    Digest::SHA256.hexdigest(data.join('-'))
  end

  def update_guest_cookie(guest)
    return unless guest&.uuid

    if private_browsing?
      cookies[:guest_uuid] = guest.uuid
    else
      cookies.permanent[:guest_uuid] = guest.uuid
    end
  end

  def private_browsing?
    begin
      cookies.permanent[:private_test] = true
      cookies.delete(:private_test)
      false
    rescue StandardError
      true
    end
  end

  def current_guest
    @current_guest
  end

  helper_method :current_guest

end
