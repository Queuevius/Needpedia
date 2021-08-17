module PostsHelper
  def allowed_to_see?(post, current_user)
    return false unless current_user

    post.private? && !post.private_users.include?(current_user)
    case post.post_type
    when Post::POST_TYPE_SUBJECT
      post.private? && !post.private_users.include?(current_user)
    when Post::POST_TYPE_PROPOSAL || POST_TYPE_PROBLEM
      post.parent_subject&.private? && !post.parent_subject&.private_users&.include?(current_user)
    when post.post_type == Post::POST_TYPE_IDEA
      post.problem&.parent_subject&.private? && !post.problem&.parent_subject&.private_users&.include?(current_user)
    when Post::POST_TYPE_LAYER
      post.parent_post&.private? && !post.parent_post&.private_users&.include?(current_user)
    else
      false
    end
  end

  def check_if_private?(post)
    response = false
    if post.post_type == Post::POST_TYPE_SUBJECT
      response = true if post.private?
    end

    if post.post_type.in?([Post::POST_TYPE_PROPOSAL, Post::POST_TYPE_PROBLEM])
      response = true if post.parent_subject&.private?
    end

    if post.post_type == Post::POST_TYPE_IDEA
      response = true if post.problem&.parent_subject&.private?
    end

    if post.post_type == Post::POST_TYPE_LAYER
      response = true if post.parent_post&.private?
    end

    response
  end

  def rating_count(ratings, number)
    ratings.where(rating: number).count
  end

  def rating_color(ratings, current_user, rating)
    return 'text-dark' if ratings.blank? || current_user.blank? || rating.blank?

    ratings&.pluck(:user_id)&.include?(current_user.id) && ratings&.where(user_id: current_user.id)&.last&.rating == rating ? 'text-primary' : 'text-dark'
  end
end
