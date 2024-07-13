class FlagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resource, only: %i[create destroy reason_modal]


  # POST /flags
  # POST /flags.json
  def create
    @flag = Flag.new(flag_params.merge(reason: params[:version_reason].presence || flag_params[:reason]))
    @resource_post_id = @flag.flagable.post.id if @flag.flagable_type == "PostVersion"

    respond_to do |format|
      if @flag.save
        if @flag.flagable_type == "Group"
          format.html {redirect_to request.referrer, notice: 'Flag was successfully added.'}
        else
          format.html {redirect_to post_path(@resource_post_id), notice: 'Flag was successfully added.'}
        end
        format.json {render :show, status: :created, location: @flag}
      else
        flash[:alert] = @flag.errors.full_messages.join(',')
        if @flag.flagable_type == "Group"
          format.html {redirect_to request.referrer}
        else
          format.html {redirect_to post_path(@resource_post_id)}
        end
        format.json {render json: @flag.errors, status: :unprocessable_entity}
      end
    end
  end


  # DELETE /flags/1
  # DELETE /flags/1.json
  def destroy
    # id is here post id
    @flag = @resource.flags.where(user_id: current_user.id).last
    @resource_post_id = @flag.flagable.post.id if @flag.flagable_type == "PostVersion"
    if @flag.blank?
      flash[:notice] = 'Not flagged'
      redirect_to post_path(@resource_post_id) and return
    end
    if @flag.destroy
      flash[:notice] = "You have unflagged this #{@klass}"
    else
      flash[:notice] = 'Some thing went wrong'
    end
    respond_to do |format|
      if @flag.flagable_type == "Group"
        format.html {redirect_to request.referrer}
      else
        redirect_to post_path(@resource_post_id)
      end
    end
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
    p_params = params[:flag].present? ? params[:flag] : params
    @klass = p_params[:flagable_type] == "PostVersion" ? p_params[:flagable_type].constantize : p_params[:flagable_type].capitalize.constantize
    @resource = @klass.find_by_id(p_params[:flagable_id])
    @resource_post_id = p_params[:flagable_type] == 'Comment' ? @resource.commentable_id : @resource.id
  end

  # Only allow a list of trusted parameters through.
  def flag_params
    params.require(:flag).permit(:reason, :flagable_id, :flagable_type, :user_id)
  end
end
