class UserTutorialsController < ApplicationController
  def update_viewed
    user_tutorial = UserTutorial.find(params[:id])
    user_tutorial.update_attribute(:viewed, true)
    render json: {success: true}
  end
end
