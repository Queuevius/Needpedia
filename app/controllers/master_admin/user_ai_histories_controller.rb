module MasterAdmin
  class MasterAdmin::UserAiHistoriesController < ApplicationController
    def show
      if params[:guest_id].present?
        @guest = Guest.find(params[:guest_id])
        @uuid = @guest.uuid
      else
        @user = User.find(params[:id])
        @uuid = @user.uuid
      end
    end
  end
end
