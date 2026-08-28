class Api::V1::PostTransformationsController < ApplicationController
  before_action :authenticate_token!
  before_action :set_post

  def show
    transform = find_transform
    if transform
      render json: { status: 200, content: { id: transform.id, content_body: transform.content_body, transform_type: transform.transform_type, created_at: transform.created_at } }
    else
      render json: { status: 404, message: 'No transformation found', content: {} }
    end
  end

  def create
    save_transform(params[:content][:body], params[:transform_type] || 'freeform') do |t|
      { status: 200, message: 'Page temporarily edited for you.', content: { id: t.id, post_id: @post.id, title: @post.title, content_body: t.content_body } }
    end
  end

  def update
    save_transform(params[:content][:body], params[:transform_type] || 'freeform') do |t|
      { status: 200, message: 'Page temporarily edited for you.', post_id: @post.id, title: @post.title }
    end
  end

  def destroy
    transform = find_transform
    if transform
      transform.destroy
      render json: { status: 200, message: 'Transformation removed. Page restored.' }
    else
      render json: { status: 404, message: 'No transformation found' }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: 404, message: 'Post not found' }
  end

  def save_transform(content_body, transform_type)
    transform = find_transform || build_transform
    transform.content_body = content_body
    transform.transform_type = transform_type
    transform.post_version_id = @post.post_versions.where(active: true).pluck(:id).first
    if transform.save
      render json: yield(transform)
    else
      render json: { status: 422, message: transform.errors.full_messages }
    end
  end

  def find_transform
    return unless @current_user || @guest
    scope = @current_user ? PostTransformation.for_user(@current_user) : PostTransformation.for_guest(@guest)
    transform = scope.for_post(@post).last
    return nil if transform&.stale?
    transform
  end

  def build_transform
    attrs = @current_user ? { user: @current_user } : { guest: @guest }
    PostTransformation.new(attrs.merge(post: @post))
  end

  def authenticate_token!
    auth_header = request.headers['Authorization']
    token = auth_header&.match(/^Bearer (.*)$/)&.[](1)
    @current_user = User.find_by(uuid: token) || User.find_by(uuid: request.headers['token'])
    @guest = @current_user ? nil : (Guest.find_by(uuid: token) || Guest.find_by(uuid: request.headers['token']))
    render json: { status: 401, message: 'Authentication required' } unless @current_user || @guest
  end
end
