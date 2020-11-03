class CommentsController < ApplicationController
  before_action :authenticate_user!

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
        format.html { redirect_to post_path(@post), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        flash[:alert] = @comment.errors.full_messages.join(',')
        format.html { redirect_to post_path(@post) }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end


  private

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :user_id)
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end
end
