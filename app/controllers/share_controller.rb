class ShareController < ApplicationController
  before_action :authenticate_user!

  def update
    @share = Share.new(share_params)
    @post = Post.find(@share.shareable_id)

    respond_to do |format|
      if @share.save
        format.html { redirect_to post_path(@post), notice: 'share was successfully added.' }
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
end
