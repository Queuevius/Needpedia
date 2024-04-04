class Api::V1::PostsController < ApplicationController
  # before_action :authenticate_token

  def index
    @subjects = Post.where(post_type: Post::POST_TYPE_SUBJECT, post_id: nil, disabled: false, private: false).includes(:ideas, :child_posts).uniq
  end

  def create
    token = extract_token_from_header
    user = User.find_by(uuid: token)

    if user.blank?
      render json: {status: '401', message: 'User must be present', content: {}}
      return
    end
    post_type = post_params[:post_type]
    subject_id = post_params[:subject_id]
    problem_id = post_params[:problem_id]

    if post_type.present?
      case post_type
      when Post::POST_TYPE_PROBLEM
        if subject_id.nil?
          render json: {status: '422', message: 'Subject id must be present', content: {}}
          return
        end
      when Post::POST_TYPE_IDEA
        if problem_id.nil?
          render json: {status: '422', message: 'Problem id must be present', content: {}}
          return
        end
      end
    end


    @post = Post.new(post_params.merge(user_id: user.id))
    if @post.save
      render json: {
          status: 'success',
          content: {
              post: {
                  link: post_url(@post),
                  title: @post.title,
                  content: @post.content.body,
                  post_type: @post.post_type,
                  curated: @post.curated,
                  group_id: @post.group_id,
                  disabled: @post.disabled,
                  private: @post.private,
              }.tap do |post_hash|
                post_hash[:problem] =
                    if @post.problem_id.present?
                      post_url(Post.find(@post.problem_id))
                    end
                post_hash[:subject] =
                    if @post.subject_id.present?
                      post_url(Post.find(@post.subject_id))
                    end
              end
          }
      }
    else
      render json: {status: '422', message: @post.errors.full_messages}
    end
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

  def post_params
    params.require(:post).permit(:title, :content, :post_type, :subject_id, :problem_id)
  end

end
