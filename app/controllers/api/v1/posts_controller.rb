class Api::V1::PostsController < ApplicationController
  # before_action :authenticate_token, except: [:index]
  # before_action :validate_post_type_presence, only: [:create]
  before_action :set_post, only: [:update]

  def index
    header_token = extract_token_from_header
    token = ENV['POST_TOKEN']
    unless header_token.present? && token.present? && header_token == token
      render json: {status: 401, message: 'Not authenticated', content: {}}
      return
    end
    @q = Post.ransack(params[:q])
    @subjects = @q.result.includes(:ideas, :child_posts).where(post_type: params[:type], post_id: nil, disabled: false, private: false).uniq
  end

  def create
    @post = Post.new(post_params.merge(user_id: current_user.id, content: post_params[:content][:body] ))
    if @post.save
      render_success_response(@post, 'Post was successfully created.')
    else
      render json: { status: 422, message: @post.errors.full_messages, content: {} }
    end
  end

  def update
    binding.pry
    if @post.update(post_params.merge(content: post_params[:content][:body] ))
      render_success_response(@post, 'Post was successfully updated.')
    else
      render json: { status: 422, message: @post.errors.full_messages, content: {} }
    end
  end

  private

  def authenticate_token
    render_unauthorized_response unless valid_token?
  end

  def validate_post_type_presence
    case post_params[:post_type]
    when Post::POST_TYPE_PROBLEM
      render_missing_param_response("Invalid subject id OR subject id is not present") unless post_params[:subject_id].present? && valid_subject_post?(post_params[:subject_id])
    when Post::POST_TYPE_IDEA
      render_missing_param_response("Invalid Problem id OR Problem id is not present") unless post_params[:problem_id].present? && valid_problem_post?(post_params[:problem_id])
    end
  end

  def render_success_response(post, message)
    render json: {
        status: 200,
        message: message,
        content: {
            post: {
                link: post_url(post),
                title: post.title,
                content: post.content.body,
                post_type: post.post_type,
                curated: post.curated,
                group_id: post.group_id,
                disabled: post.disabled,
                private: post.private,
                problem: post.problem_id.present? ? post_url(Post.find(post.problem_id)) : nil,
                subject: post.subject_id.present? ? post_url(Post.find(post.subject_id)) : nil
            }
        }
    }
  end

  def render_unauthorized_response
    render json: {status: 401, message: 'User must be present', content: {}}
  end

  def render_missing_param_response(message)
    render json: {status: 422, message: message, content: {}}
  end

  def valid_token?
    extract_token_from_header.present? && current_user.present?
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    header&.match(/^Bearer (.*)$/) {$1}
  end

  def post_params
    params[:post].permit(:title, :post_type, :subject_id, :problem_id, :parent_id, content: [:body])
  end

  def current_user
    @current_user ||= User.find_by(uuid: request.headers['token'])
  end

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: 404, message: 'Post not found', content: {} }
  end

  def valid_subject_post?(id)
    post = Post.find_by(id: id)
    post.present? && post&.post_type == Post::POST_TYPE_SUBJECT
  end

  def valid_problem_post?(id)
    post = Post.find_by(id: id)
    post.present? && post&.post_type == Post::POST_TYPE_PROBLEM
  end
end
