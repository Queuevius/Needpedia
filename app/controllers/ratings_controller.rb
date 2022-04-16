class RatingsController < ApplicationController
  before_action :authenticate_user!

  def change_rating
    @rating = Rating.new(rating_params)
    @post = Post.includes(:ratings).find(@rating.rateable_id)

    old = Rating.where(user_id: current_user.id, rateable_id: @rating.rateable_id, rateable_type: @rating.rateable_type)
    if old.pluck(:rating).include?(@rating.rating)
      old.destroy_all
      @rating = nil
    else
      @rating.user = current_user
      @rating.save
      old.where.not(id: @rating.id).destroy_all
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def rating_params
    params.permit(:rateable_id, :rateable_type, :user_id, :rating)
  end

  def voted?(argument)
    argument.ratings.pluck(:user_id).include?(current_user.id) || argument.flags.pluck(:user_id).include?(current_user.id)
  end
end
