module PostsHelper
  def allowed_to_see?(post, current_user)

    if current_user.present? && check_if_private?(post)
      post.private? && !post.private_users.include?(current_user)
      case post.post_type
      when Post::POST_TYPE_SUBJECT
        post.private? && !post.private_users.include?(current_user)
      when Post::POST_TYPE_PROBLEM
        post.parent_subject&.private? && !post.parent_subject&.private_users&.include?(current_user)
      when post.post_type == Post::POST_TYPE_IDEA
        post.problem&.parent_subject&.private? && !post.problem&.parent_subject&.private_users&.include?(current_user)
      when Post::POST_TYPE_LAYER
        post.parent_post&.private? && !post.parent_post&.private_users&.include?(current_user)
      else
        false
      end
    elsif current_user.blank? && check_if_private?(post)
      return true
    else
      return false
    end
  end

  def check_if_private?(post)
    response = false
    if post.post_type == Post::POST_TYPE_SUBJECT
      response = true if post.private?
    end

    if post.post_type.in?([Post::POST_TYPE_PROBLEM])
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

  def post_content_for_map(post)
    post&.content&.to_plain_text&.squish&.delete('\\"')
  end

  def group_info
    content_tag(:p) do
      concat("Created by ")
      concat(link_to(@post.user.name, wall_path(uuid: uuid)))
      concat(" as a ")
      concat(group_role)
      concat(" of ")
      concat(link_to(@group.name, @group))
      concat(" group")
    end
  end

  def post_user_name
    @post.user.name
  end

  def uuid
    @post.user.uuid
  end

  def group_role
    if @group.user == current_user
      " admin "
    else
      " member "
    end
  end
end
