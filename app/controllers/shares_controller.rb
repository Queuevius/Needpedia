class SharesController < ApplicationController
  before_action :authenticate_user!

  def create
    @share = Share.new(share_params)
    @post = Post.find(@share.shareable_id)

    respond_to do |format|
      if @share.save
        if @share.shareable_type == 'Post'
          create_activity(@share.shareable, 'post.share')
        end
        format.html { redirect_to post_path(@post), notice: "You shared #{@post.title}." }
        format.json { render :show, status: :created, location: @share }
      else
        flash[:alert] = @share.errors.full_messages.join(',')
        format.html { redirect_to post_path(@post) }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def share_params
    params.permit(:shareable_id, :shareable_type, :user_id)
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user, ip: request.remote_ip).call
  end
end
