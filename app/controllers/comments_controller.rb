class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_comment, only: [:remove_comment, :inappropriate]


  def index
    @post = Post.find(params[:post_id])
    @comments = @post.comments.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(5).order('comments.created_at DESC')
  end

  def new
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(parent_id: params[:parent_id])
  end

  def edit
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    @post = Post.find(@comment.commentable_id)

    respond_to do |format|
      if @comment.save
        if @comment.commentable_type == 'Post'
          create_activity(@comment.commentable, 'post.commented_on')
        end
        format.js
        format.html {redirect_to post_path(@post), notice: 'Comment was successfully created.'}
        format.json {render :show, status: :created, location: @comment}
      else
        flash[:alert] = @comment.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @comment.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @post = Post.find(@comment.commentable_id)

    respond_to do |format|
      if @comment.update(comment_params)
        format.html {redirect_to post_path(@post), notice: 'Comment was successfully updated.'}
        format.json {render :edit, status: :created, location: @comment}
      else
        flash[:alert] = @comment.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @comment.errors, status: :unprocessable_entity}
      end
    end
  end

  def remove_comment
    if @comment.destroy
      redirect_to post_path(@post), notice: 'Comment successfully deleted.'
    else
      flash[:alert] = @comment.errors.full_messages.join(',')
      redirect_to post_path(@post)
    end
  end

  def inappropriate
    if @comment.update(inappropriate: true)
      redirect_to post_path(@post), notice: 'Comment successfully marked inappropriate.'
    else
      flash[:alert] = @comment.errors.full_messages.join(',')
      redirect_to post_path(@post)
    end
  end


  private

  def find_comment
    @post = Post.find(params[:post_id])
    @comment = @post.comments.active.find(params[:comment_id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :user_id, :parent_id)
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end
end
