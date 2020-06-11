class FlagsController < ApplicationController
  before_action :authenticate_user!


  # POST /flags
  # POST /flags.json
  def create
    @flag = Flag.new(flag_params)
    @post = Post.find(@flag.flagable_id)

    respond_to do |format|
      if @flag.save
        format.html { redirect_to post_path(@post), notice: 'Flag was successfully added.' }
        format.json { render :show, status: :created, location: @flag }
      else
        flash[:alert] = @flag.errors.full_messages.join(',')
        format.html { redirect_to post_path(@post) }
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /flags/1
  # DELETE /flags/1.json
  def destroy
    # id is here post id
    @post = Post.find(params[:id])
    @flag = @post.flags.where(user_id: current_user.id).last
    if @flag.blank?
      flash[:notice] = 'Not flagged'
      redirect_to post_path(@post) and return
    end
    if @flag.destroy
      flash[:notice] = 'You have unflagged this Post'
    else
      flash[:notice] = 'Some thing went wrong'
    end
    redirect_to post_path(@post)
  end

  # GET /flags/reason_modal
  def reason_modal
    @post = Post.find_by_id(params[:post_id])
    @flag = Flag.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def flag_params
    params.require(:flag).permit(:reason, :flagable_id, :flagable_type, :user_id)
  end
end
