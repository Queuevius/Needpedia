class RatingsController < ApplicationController
  before_action :authenticate_user!

  def change_rating
    @rating = Rating.new(rating_params)

    old = Rating.where(user_id: current_user.id, rateable_id: @rating.rateable_id, rateable_type: @rating.rateable_type)
    if old.present?
      old.destroy_all
    end

    @rating.user = current_user
    @post = Post.includes(:ratings).find(@rating.rateable_id)
    @rating.save
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
