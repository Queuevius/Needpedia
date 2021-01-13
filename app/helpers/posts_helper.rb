module PostsHelper
  def allowed_to_see?(post, current_user)
    post.private? && !post.private_users.include?(current_user)
    case post.post_type
    when Post::POST_TYPE_AREA
      post.private? && !post.private_users.include?(current_user)
    when Post::POST_TYPE_PROPOSAL || POST_TYPE_PROBLEM
      post.parent_area&.private? && !post.parent_area&.private_users&.include?(current_user)
    when post.post_type == Post::POST_TYPE_IDEA
      post.problem&.parent_area&.private? && !post.problem&.parent_area&.private_users&.include?(current_user)
    when Post::POST_TYPE_LAYER
      post.parent_post&.private? && !post.parent_post&private_users&.include?(current_user)
    else
      false
    end
  end
end
