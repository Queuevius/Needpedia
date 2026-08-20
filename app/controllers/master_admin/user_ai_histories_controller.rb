module MasterAdmin
  class UserAiHistoriesController < MasterAdmin::ApplicationController
    def show
      if params[:guest_id].present?
        @guest = Guest.find(params[:guest_id])
        @uuid = @guest.uuid
      elsif params[:id].present?
        @user = User.find(params[:id])
        @uuid = @user.uuid
      elsif params[:user_token].present?
        @guest = Guest.find_by(uuid: params[:user_token])
        @uuid = @guest&.uuid || params[:user_token]
      else
        redirect_to '/master_admin', alert: 'Missing user identifier'
      end
    end
  end
end
