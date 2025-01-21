module MasterAdmin
  class MasterAdmin::UserAiHistoriesController < ApplicationController
    def show
      @user = User.find(params[:id])
      @uuid = @user.uuid
    end
  end
end
