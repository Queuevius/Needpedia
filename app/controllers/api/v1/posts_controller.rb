class Api::V1::PostsController < ApplicationController
  def index
    @subjects = Post.where(post_type: Post::POST_TYPE_SUBJECT, post_id: nil)
                   .includes(:problem, :ideas, :child_posts)
                   .uniq
  end
end
