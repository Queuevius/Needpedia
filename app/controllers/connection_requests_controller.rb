class ConnectionRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_connection_request, only: [:accept, :reject]
  before_action :check_user, only: [:create]

  # GET /connection_requests
  # GET /connection_requests.json
  def index
    # get the pending requests of current user
    @connection_requests = ConnectionRequest.where(to: current_user.uuid, status: 'pending')
  end


  # GET /connection_requests/new
  def new
    @request_to = User.find_by uuid: params[:uuid]
    @connection_request = ConnectionRequest.new
  end


  # POST /connection_requests
  # POST /connection_requests.json
  def create
    request = ConnectionRequest.new(connection_request_params)
    request.user = current_user
    if request.save!
      request_to = User.find_by uuid: request.to
      Notification.post(from: current_user, notifiable: current_user, to: request_to, action: Notification::NOTIFICATION_TYPE_FRIEND_REQUEST)
      flash[:success] = "Connection request was successfully sent to #{request_to.name}."
      redirect_to friends_path
    else
      flash[:error] = 'Something went wrong please try again.'
      redirect_back(fallback_location: friends_path)
    end
  end

  def accept
    if @connection_request
      connection = current_user.connections.build(:friend_id => @connection_request.user.id)
      connected_with = User.find @connection_request.user_id
      if connection.save
        flash[:success] = "You are now connected with #{connected_with.name}."

        # update the status of sent request
        @connection_request.status = 'accepted'
        @connection_request.save
        Notification.post(from: current_user, notifiable: current_user, to: @connection_request.user, action: Notification::NOTIFICATION_TYPE_REQUEST_ACCEPTED)
        redirect_back(fallback_location: friends_path)
      else
        flash[:alert] = "You are already connected with #{connected_with.name}."
        redirect_back(fallback_location: friends_path)
      end
    else
      flash[:alert] = 'We could not process your request, please try again.'
      redirect_back(fallback_location: friends_path)
    end
  end

  def reject

    @connection_request.status = 'rejected'
    @connection_request.save
    Notification.post(from: current_user, notifiable: @connection_request.user, to: request_to, action: Notification::NOTIFICATION_TYPE_REQUEST_REJECTED)
    redirect_to connection_requests_url, notice: 'Connection request has been rejected.'
  end

  private

  # just an extra check that makes user param has not been tampered with
  def check_user
    user = User.find_by uuid: params[:connection_request][:to]
    if user.blank?
      flash[:error] = 'Something went wrong please try again.'
      redirect_back(fallback_location: friends_path)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_connection_request
    @connection_request = ConnectionRequest.find_by uuid: params[:uuid]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def connection_request_params
    params.require(:connection_request).permit(:message, :to)
  end
end
