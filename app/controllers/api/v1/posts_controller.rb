class Api::V1::PostsController < ApplicationController
  before_action :authenticate_token, except: [:index]
  before_action :validate_post_type_presence, only: [:create]
  before_action :set_post, only: [:update]

  def index
    header_token = extract_token_from_header
    token = ENV['POST_TOKEN']
    unless header_token.present? && token.present? && header_token == token
      render json: {status: 401, message: 'Not authenticated', content: {}}
      return
    end

    # If post_id is provided, find that specific post
    if params[:post_id].present?
      @post = Post.find_by(id: params[:post_id], disabled: false, private: false)

      unless @post
        render json: { status: 404, message: 'Post not found', content: {} }
        return
      end

      # Determine what to include based on post type
      json_options = { methods: [:url] }

      case @post.post_type
      when Post::POST_TYPE_SUBJECT
        # Load problems and their ideas
        @post = Post.includes(child_posts: :ideas).find(@post.id)
        json_options[:include] = {
            child_posts: {
                only: [:id, :post_type, :title, :subject_id],
                methods: [:url, :content],
                include: {
                    ideas: {
                        only: [:id, :post_type, :title, :problem_id],
                        methods: [:url, :content]
                    }
                }
            }
        }
      when Post::POST_TYPE_PROBLEM
        # Load ideas
        @post = Post.includes(:ideas).find(@post.id)
        json_options[:include] = {
            ideas: {
                only: [:id, :post_type, :title, :problem_id],
                methods: [:url, :content]
            }
        }
      when Post::POST_TYPE_IDEA
        # No children to load
        json_options[:include] = {}
      end

      render json: {
          status: 200,
          message: 'OK',
          content: @post.as_json(json_options)
      }
      return
    end

    # Original logic for listing posts
    @q = Post.ransack(params[:q])

    scope = @q.result.where(disabled: false, private: false)

    # Filter by type if specified and not 'all'
    if params[:type].present? && params[:type].downcase != 'all'
      case params[:type].downcase
      when 'subject'
        # Top-level subjects only
        scope = scope.where(post_type: Post::POST_TYPE_SUBJECT, subject_id: nil)
      when 'problem'
        # Problems belong to subjects
        scope = scope.where(post_type: Post::POST_TYPE_PROBLEM).where.not(subject_id: nil)
      when 'idea'
        # Ideas belong to problems
        scope = scope.where(post_type: Post::POST_TYPE_IDEA).where.not(problem_id: nil)
      else
        # Handle other post types if needed
        scope = scope.where(post_type: params[:type])
      end
    else
      # When returning all types, get only top-level subjects
      scope = scope.where(post_type: Post::POST_TYPE_SUBJECT, subject_id: nil)
    end

    # Load the full hierarchy for 'all' or no type specified
    if params[:type].blank? || params[:type].downcase == 'all'
      # Subject has child_posts (problems), and problems have ideas
      scope = scope.includes(child_posts: :ideas)
    end
    @posts = scope.distinct

    include_children = ActiveModel::Type::Boolean.new.cast(params[:include_children])

    # Build JSON response
    json_options = {
        methods: [:url],
        include: {}
    }

    # Include hierarchy when returning all types or include_children is true
    if params[:type].blank? || params[:type].downcase == 'all' || include_children
      json_options[:include][:child_posts] = {
          only: [:id, :post_type, :title, :subject_id],
          methods: [:url, :content],
          include: {
              ideas: {
                  only: [:id, :post_type, :title, :problem_id],
                  methods: [:url, :content]
              }
          }
      }
    end

    render json: {
        status: 200,
        message: 'OK',
        content: @posts.as_json(json_options)
    }
  end

  def create
    @post = Post.new(post_params.except(:content).merge(user_id: current_user.id))

    # Set the rich text content from nested body parameter
    if post_params[:content].present? && post_params[:content][:body].present?
      @post.content = post_params[:content][:body]
    end

    if @post.save
      render_success_response(@post, 'Post was successfully created.')
    else
      render json: { status: 422, message: @post.errors.full_messages, content: {} }
    end
  end

  def update
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
    params.require(:post).permit(:title, :post_type, :subject_id, :problem_id, :post_id, :posted_to_id, content: [:body])
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
