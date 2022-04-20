class RatingsController < ApplicationController
  before_action :authenticate_user!

  def change_rating
    @rating = Rating.new(rating_params)
    @post = Post.includes(:ratings).find(@rating.rateable_id)

    old = Rating.where(user_id: current_user.id, rateable_id: @rating.rateable_id, rateable_type: @rating.rateable_type)

    if @rating.rating == Rating::LOL_RATING
      old_lol = old.where(rating: Rating::LOL_RATING)
      if old_lol.present?
        delete_rating(old_lol)
        @rating = old.where.not(rating: Rating::LOL_RATING).last
      else
        save_rating(@rating)
      end
    else
      old = old.where.not(rating: Rating::LOL_RATING)
      if old.pluck(:rating).include?(@rating.rating)
        delete_rating(old)
        @rating = nil
      else
        save_rating(@rating)
        delete_rating(old.where.not(id: @rating.id))
      end
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

  def save_rating(rating)
    rating.user = current_user
    rating.save
  end

  def delete_rating(ratings)
    ratings.destroy_all
  end
end
