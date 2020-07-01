class ProfileController < ApplicationController
  before_action :set_user, only: [:wall, :about, :friends, :friend_request, :pictures]
  before_action :friend_count, only: [:wall, :about, :friends, :friend_request, :pictures]
  before_action :connection_requests_count, only: [:wall, :about, :friends, :friend_request, :pictures]

  def wall
    @posted_posts = @user.posts.where(post_type: Post::POST_TYPE_AREA)
    @liked_posts = @user.likes.collect(&:likeable)
    @commented_posts = @user.comments.collect(&:commentable)
    @flagged_posts = @user.flags.collect(&:flagable)
    @shared_posts = @user.shares.collect(&:shareable)
  end

  def about; end

  def friends
    @f = User.ransack(params[:f])
    @friends = Kaminari.paginate_array(@user.links).page(params[:page]).per(12)
  end

  def friend_request
    @connection_requests = ConnectionRequest.where(to: @user.uuid, status: 'pending').page(params[:page]).per(12)
  end

  def pictures; end

  def modal_picture
    @picture = current_user.pictures.find_by_id(params[:id])
  end

  def my_connections
    @keywords = params[:first_name]
    @f = User.ransack(first_name: @keywords)
    @friends = @f.result.order("random()").page(params[:page]).per(12)
  end

  def search_results
    @f = User.ransack(params[:f])
    @friends = @f.result.order("random()").page(params[:page]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def add_details
    @user = current_user
  end

  def update_details
    @user = User.find(params[:user][:user_id])

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to add_details_path, notice: 'Aad detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        flash[:alert] = @user.errors.full_messages.join(',')
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:location, :about, :profile_image, pictures: [])
  end

  def set_user
    if params[:uuid].present?
      @user = User.find_by(uuid: params[:uuid])
      @uuid = params[:uuid]
    else
      @user = current_user
    end
  end

  def friend_count
    @friends_count = Kaminari.paginate_array(@user.links)
  end

  def connection_requests_count
    @connection_requests_count = ConnectionRequest.where(to: @user.uuid, status: 'pending')
  end

end
