class FlagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resource, only: %i[destroy reason_modal]


  # POST /flags
  # POST /flags.json
  def create
    @flag = Flag.new(flag_params)
    @resource = Post.find(@flag.flagable_id)

    respond_to do |format|
      if @flag.save
        format.html { redirect_to post_path(@resource), notice: 'Flag was successfully added.' }
        format.json { render :show, status: :created, location: @flag }
      else
        flash[:alert] = @flag.errors.full_messages.join(',')
        format.html { redirect_to post_path(@resource) }
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /flags/1
  # DELETE /flags/1.json
  def destroy
    # id is here post id
    @flag = @resource.flags.where(user_id: current_user.id).last
    if @flag.blank?
      flash[:notice] = 'Not flagged'
      redirect_to post_path(@flag.flagable) and return
    end
    if @flag.destroy
      flash[:notice] = "You have unflagged this #{@klass}"
    else
      flash[:notice] = 'Some thing went wrong'
    end
    redirect_to post_path(@flag.flagable)
  end

  # GET /flags/reason_modal
  def reason_modal
    @flag = Flag.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def set_resource
    @klass = params[:flagable_type].capitalize.constantize
    @resource = @klass.find_by_id(params[:flagable_id])
  end

  # Only allow a list of trusted parameters through.
  def flag_params
    params.require(:flag).permit(:reason, :flagable_id, :flagable_type, :user_id)
  end
end
