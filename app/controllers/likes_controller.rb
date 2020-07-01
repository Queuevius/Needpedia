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
end
