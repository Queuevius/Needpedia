class Api::V1::PostsController < ApplicationController
  before_action :authenticate_token

  def index
    @subjects = Post.where(post_type: Post::POST_TYPE_SUBJECT, post_id: nil, disabled: false, private: false).includes(:ideas, :child_posts).uniq
  end

  private

  def authenticate_token
    unless ENV['AUTH_TOKEN'].present? && valid_token?
      render json: {error: 'Not authorized'}, status: :unauthorized
    end
  end

  def valid_token?
    token = extract_token_from_header
    token.present? && token == ENV['AUTH_TOKEN']
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    if header && header.match(/^Bearer (.*)$/)
      return $1
    else
      return nil
    end
  end
end
