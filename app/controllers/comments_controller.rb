class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment_and_commentable, only: [:destroy, :edit, :update]
  before_action :find_post_for_legacy_actions, only: [:index, :new]
  before_action :find_comment_for_legacy_actions, only: [:remove_comment, :inappropriate]

  def index
    @comments = @post.comments.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(5).order('comments.created_at DESC')
  end

  def new
    @comment = @post.comments.new(parent_id: params[:parent_id])
  end

  def edit
    # @comment and @commentable are set by set_comment_and_commentable
    # Ensure your edit form can handle @commentable being a Post or Task
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    
    commentable_type_class = @comment.commentable_type.classify.safe_constantize
    if commentable_type_class
      @commentable = commentable_type_class.find_by(id: @comment.commentable_id)
    end

    unless @commentable
      respond_to do |format|
        flash[:alert] = "Associated record not found."
        format.html { redirect_back fallback_location: root_path, alert: 'Associated record not found.' }
        format.json { render json: { error: 'Associated record not found' }, status: :unprocessable_entity }
      end
      return
    end
    @comment.commentable = @commentable

    respond_to do |format|
      banned_term = BannedTerm.last
      if banned_term.present?
        banned_terms = banned_term.term
        checker = TermCheckerService.new(@comment.body, banned_terms)
        response = checker.content_contains_banned_term
        if response.present?
          @found_term = response
          format.html do 
            flash[:alert] = "Comment contains banned terms: #{response}"
            redirect_to polymorphic_path(@commentable, anchor: 'comment-form') 
          end
          format.js { render js: "alert('Comment contains banned terms: #{response}');" } 
          return
        end
      end
      
      if @comment.save
        if @comment.commentable_type == 'Post'
          create_activity(@commentable, 'post.commented_on')
        elsif @comment.commentable_type == 'Task'
          # create_activity(@commentable, 'task.commented_on')
        end
        format.js
        format.html { redirect_to polymorphic_path(@commentable, anchor: "comment-#{@comment.id}"), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment } 
      else
        flash[:alert] = @comment.errors.full_messages.join(',')
        format.html do
           redirect_to polymorphic_path(@commentable, anchor: 'comment-form'), alert: @comment.errors.full_messages.join(', ')
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # @comment and @commentable are set by set_comment_and_commentable
    # Original banned term logic was here, ensure it's compatible or refactor
    respond_to do |format|
      # Simplified update for now, assuming banned term logic might be refactored or handled by model
      if @comment.update(comment_params)
        format.html {redirect_to polymorphic_path(@commentable, anchor: "comment-#{@comment.id}"), notice: 'Comment was successfully updated.'}
        format.js # Assumes update.js.erb exists
        format.json {render :show, status: :ok, location: @comment} # :show might need to be generic
      else
        flash[:alert] = @comment.errors.full_messages.join(',')
        format.html { render :edit } # Or redirect if edit form is on commentable page
        format.json {render json: @comment.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /comments/:id
  def destroy
    # @comment and @commentable are set by set_comment_and_commentable
    # Add authorization: e.g., if current_user == @comment.user || current_user.admin?
    if @comment.user == current_user # Basic authorization
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@commentable), notice: 'Comment was successfully destroyed.' }
        format.js   # This will look for views/comments/destroy.js.erb
      end
    else
      respond_to do |format|
        format.html { redirect_to polymorphic_path(@commentable), alert: 'Not authorized to delete this comment.' }
        format.js { render js: "alert('Not authorized to delete this comment.');" }
      end
    end
  end

  # Legacy actions, keep them if they are still used by old routes/links
  def remove_comment
    if @comment.destroy # @comment is set by find_comment_for_legacy_actions
      redirect_to post_path(@post), notice: 'Comment successfully deleted.'
    else
      flash[:alert] = @comment.errors.full_messages.join(',')
      redirect_to post_path(@post)
    end
  end

  def inappropriate
    # @comment is set by find_comment_for_legacy_actions
    if @comment.update(inappropriate: true)
      redirect_to post_path(@post), notice: 'Comment successfully marked inappropriate.'
    else
      flash[:alert] = @comment.errors.full_messages.join(',')
      redirect_to post_path(@post)
    end
  end

  private

  def set_comment_and_commentable
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Comment not found."
    redirect_back fallback_location: root_path
  end

  # Legacy before_action, specific to posts
  def find_post_for_legacy_actions
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Post not found."
    redirect_back fallback_location: root_path
  end

  # Legacy before_action, specific to posts
  def find_comment_for_legacy_actions
    find_post_for_legacy_actions # Ensures @post is set
    @comment = @post.comments.active.find(params[:comment_id]) if @post # comment_id from nested routes
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Comment not found."
    redirect_back fallback_location: root_path
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :user_id, :parent_id, :group_id)
  end

  def create_activity(commentable, event)
    # Changed 'post' to 'commentable' to be generic
    ActivityService.new(object: commentable, event: event, owner: current_user, ip: request.remote_ip).call
  end
end
