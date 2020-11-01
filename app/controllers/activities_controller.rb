class ActivitiesController < ApplicationController
  def index
    @user = current_user
    @activities = PublicActivity::Activity.order('created_at DESC').limit(20)
  end
end
