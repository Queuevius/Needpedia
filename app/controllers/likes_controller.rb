class LikesController < ApplicationController
  before_action :authenticate_user!


  # POST /likes
  # POST /likes.json
  def update
    @like = Like.new(like_params)
    @post = Post.find(@like.likeable_id)

    respond_to do |format|
      if @like.save
        format.html { redirect_to post_path(@post), notice: 'Like was successfully added.' }
        format.json { render :show, status: :created, location: @like }
      else
        flash[:alert] = @like.errors.full_messages.join(',')
        format.html { redirect_to post_path(@post) }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  def upvote
    @like = Like.new(like_params)
    post_token_type = params[:post_token_type]
    post_token_id = params[:post_token_id]
    @debate = TokenAnsDebate.find(@like.likeable_id)
    url = "/post_tokens/#{post_token_type}?id=#{post_token_id}"
    if voted?(@like.likeable)
      redirect_to url, alert: 'You have already voted.'
      return
    end
    respond_to do |format|
      if @like.save
        format.html { redirect_to url, notice: 'You added an Up vote.'}
        format.json { render :show, status: :created, location: @like }
      else
        flash[:alert] = @like.errors.full_messages.join(',')
        format.html { redirect_to url, notice: 'Something went wrong while adding an Up vote.'}
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  def downvote
    @flag = Flag.new(flag_params)
    post_token_type = params[:post_token_type]
    post_token_id = params[:post_token_id]
    @debate = TokenAnsDebate.find(@flag.flagable_id)
    url = "/post_tokens/#{post_token_type}?id=#{post_token_id}"
    if voted?(@flag.flagable)
      redirect_to url, alert: 'You have already voted.'
      return
    end
    respond_to do |format|
      if @flag.save
        format.html { redirect_to url, notice: 'You added a Down vote.'}
        format.json { render :show, status: :created, location: @flag }
      else
        flash[:alert] = @flag.errors.full_messages.join(',')
        format.html { redirect_to url, notice: 'Something went wrong while adding a Down vote.'}
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /likes/1
  # DELETE /likes/1.json
  def destroy
    # id is here post id
    @post = Post.find(params[:id])
    @like = @post.likes.where(user_id: current_user.id).last
    if @like.blank?
      flash[:notice] = 'Not like'
      redirect_to post_path(@post) and return
    end
    if @like.destroy
      # flash[:notice] = 'You have unlike this Post'
    else
      flash[:notice] = 'Some thing went wrong'
    end
    redirect_to post_path(@post)
  end

  private

  # Only allow a list of trusted parameters through.
  def like_params
    params.permit(:likeable_id, :likeable_type, :user_id)
  end
  def flag_params
    params.permit(:flagable_id, :flagable_type, :user_id)
  end

  def voted?(argument)
    argument.likes.pluck(:user_id).include?(current_user.id) || argument.flags.pluck(:user_id).include?(current_user.id)
  end
end
