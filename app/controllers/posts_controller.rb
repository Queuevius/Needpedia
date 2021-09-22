class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :update, :create, :edit]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_type, only: [:index, :new, :problems, :proposals, :ideas, :layers]
  before_action :set_area, only: [:proposals, :problems, :ideas, :layers, :track_post]
  before_action :set_user, only: :new
  after_action :send_update_email, only: [:update]

  # GET /posts
  # GET /posts.json
  # Area posts
  def index
    if params[:tag]
      @posts = Post.tagged_with(params[:tag])
    else
      @posts = Post.posts_feed.where.not(post_type: Post::POST_TYPE_SOCIAL_MEDIA).order('created_at desc')
    end
  end

  def problems
    post_type = 'problem'
    sorted_by = 'Highest-Rated'
    access_type = 'Public'
    q = { title_cont: '', user_first_name_cont: '' }
    redirect_to search_result_posts_path(q: q, post_type: post_type, sorted_by: sorted_by, access_type: access_type)
  end

  def ideas
    post_type = 'idea'
    sorted_by = 'Highest-Rated'
    access_type = 'Public'
    q = { title_cont: '', user_first_name_cont: '' }
    redirect_to search_result_posts_path(q: q, post_type: post_type, sorted_by: sorted_by, access_type: access_type)
  end

  def layers
    @posts = Post.layer_posts.where(post_id: @post.id)
  end

  def all_areas
    @posts = Post.area_posts
  end

  def all_problems
    @posts = Post.problem_posts
  end

  def all_ideas
    @posts = Post.idea_posts
  end

  def all_layers
    @posts = Post.layer_posts
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @comment = Comment.new(parent_id: params[:parent_id])
    @comments = @post.comments.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(12).order('comments.created_at ASC')
  end

  # GET /posts/new
  def new
    @subject_id = params[:subject_id]
    @problem_id = params[:problem_id]
    @post_id = params[:post_id]
    if params[:post] && params[:post][:from_feed]
      if [Post::POST_TYPE_PROBLEM].include?(@type)
        @subject_id = Post::GENERAL_AREA
      elsif @type == Post::POST_TYPE_IDEA
        @problem_id = Post::GENERAL_PROBLEM
      else
      end
    end
    @post = Post.new(post_type: @type)
    @private_users = @post.private_users << current_user
    @curated_users = @post.curated_users << current_user
  end

  # GET /posts/1/edit
  def edit
    @private_users = @post.private_users
    @curated_users = @post.curated_users
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        # @post.clean_froala_link
        UserPrivatePost.create(post_id: @post.id, user_id: current_user&.id) if @post.post_type == Post::POST_TYPE_SUBJECT
        UserCuratedPost.create(post_id: @post.id, user_id: current_user&.id) if @post.post_type == Post::POST_TYPE_SUBJECT
        check_if_should_be_private(@post)
        check_if_should_be_curated(@post)
        create_private_users
        create_curated_users
        create_activity(@post, 'post.create')
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        flash[:alert] = @post.errors.full_messages.join(',')
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        create_private_users
        create_curated_users
        # @post.clean_froala_link
        Notification.post(from: current_user, notifiable: current_user, to: @post.users, action: Notification::NOTIFICATION_TYPE_POST_UPDATED, post_id: @post.id)
        create_activity(@post, 'post.update')
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        flash[:alert] = @post.errors.full_messages.join(',')
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to wall_path, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def destroy_activity
    @activity = PublicActivity::Activity.find(params[:id])
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to feed_path, notice: 'Post was successfully destroyed.' }
    end
  end

  def remove_private_user
    @post = Post.find(params[:post_id])
    user_id = params[:user_id]
    user = User.find(user_id)
    user_private_post = UserPrivatePost.where(post_id: @post.id, user_id: user_id)
    if user_id && user_private_post.present?
      user_private_post.destroy_all
      Notification.post(from: current_user, notifiable: user, to: user, action: Notification::NOTIFICATION_TYPE_POST_USER_REMOVED, post_id: @post.id)
      flash[:notice] = 'User removed successfully'
    else
      flash[:alert] = 'Something went wrong, please try later'
    end
    redirect_to edit_post_path(@post)
  end

  def remove_curated_user
    @post = Post.find(params[:post_id])
    user_id = params[:user_id]
    user = User.find(user_id)
    user_curated_post = UserCuratedPost.where(post_id: @post.id, user_id: user_id)
    if user_id && user_curated_post.present?
      user_curated_post.destroy_all
      Notification.post(from: current_user, notifiable: user, to: user, action: Notification::NOTIFICATION_TYPE_POST_CURATED_USER_REMOVED, post_id: @post.id)
      flash[:notice] = 'User removed successfully'
    else
      flash[:alert] = 'Something went wrong, please try later'
    end
    redirect_to edit_post_path(@post)
  end

  def search_result
    @keywords = params[:q]
    @active_tab = 'posts'
    if @keywords[:first_name_or_last_name_or_full_name_cont].present?
      @active_tab = 'people'
      query_service = UserSearchService.new(params)
      users = query_service.filter
      @users = Kaminari.paginate_array(users).page(params[:users]).per 10
      @posts = Kaminari.paginate_array([]).page(params[:posts]).per 10
    else
      query_service = PostSearchService.new(params)
      posts = query_service.filter
      @posts = Kaminari.paginate_array(posts).page(params[:posts]).per 10
      @access_type = params[:access_type]
      @post_type = params[:post_type]
      @sorted_by = params[:sorted_by]
      @subject = params[:subject]
      @problem = params[:problem]
      @idea = params[:idea]
      @location_tags = params[:location_tags]
      @resource_tags = params[:resource_tags]
      @users = Kaminari.paginate_array([]).page(params[:users]).per 10
    end
  end

  def track_post
    begin
      tracking_post = current_user.tracking_posts.where(post_id: @post.id)
      if tracking_post.present?
        tracking_post.destroy_all
        # flash[:notice] = 'You have DeActivated Tracking for this Post.'
      else
        UserPost.create!(user_id: current_user.id, post_id: @post.id, post_type: @post.post_type)
        # flash[:notice] = 'You have activated Tracking for this Post.'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_back(fallback_location: post_path(@post))
  end

  def modal
    @post = Post.new
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    if params[:uuid].present?
      @posted_to = User.find_by(uuid: params[:uuid])
      @uuid = params[:uuid]
    else
      @posted_to = current_user
    end
  end

  def set_post
    @post = Post.find_by_id(params[:id])
  end

  def create_private_users
    user_ids = params[:post][:user_ids]
    return unless user_ids.present?

    user_ids.each do |user|
      post = UserPrivatePost.where(post_id: @post.id, user_id: user.to_i)
      UserPrivatePost.create(post_id: @post.id, user_id: user.to_i) if post.blank?

      user = User.find(user.to_i)
      Notification.post(from: current_user, notifiable: user, to: user, action: Notification::NOTIFICATION_TYPE_POST_USER_ADDED, post_id: @post.id)
    end
  end

  def create_curated_users
    user_ids = params[:post][:curated_user_ids]
    return unless user_ids.present?

    user_ids.each do |user|
      post = UserCuratedPost.where(post_id: @post.id, user_id: user.to_i)
      UserCuratedPost.create(post_id: @post.id, user_id: user.to_i) if post.blank?

      user = User.find(user.to_i)
      Notification.post(from: current_user, notifiable: user, to: user, action: Notification::NOTIFICATION_TYPE_POST_CURATED_USER_ADDED, post_id: @post.id)
    end
  end

  def check_if_should_be_private(post)
    case true
    when post.post_type.in?([Post::POST_TYPE_PROBLEM])
      post.update(private: true) if post.parent_subject&.private?
    when post.post_type == Post::POST_TYPE_IDEA
      post.update(private: true) if post.problem&.parent_subject&.private?
    when post.post_type == Post::POST_TYPE_LAYER
      post.update(private: true) if post.parent_post&.private?
    else
      true
    end
  end

  def check_if_should_be_curated(post)
    case true
    when post.post_type.in?([Post::POST_TYPE_PROBLEM])
      post.update(private: true) if post.parent_subject&.curated?
    when post.post_type == Post::POST_TYPE_IDEA
      post.update(private: true) if post.problem&.parent_subject&.curated?
    when post.post_type == Post::POST_TYPE_LAYER
      post.update(private: true) if post.parent_post&.curated?
    else
      true
    end
  end

  def set_area
    @post = Post.find_by_id(params[:post_id])
  end

  def set_type
    @type = params[:post_type] || Post::POST_TYPE_SUBJECT
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :content, :user_id, :post_type, :subject_id, :problem_id, :private, :curated, :post_id, :posted_to_id, :tag_list, :resource_tag_list, images: [])
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end

  def send_update_email
    @post.users.each do |user|
      next if user.all_notifications? || user.daily_notifications? || !user.track_notifications?

      UserMailer.send_tracking_email(actor: current_user, receiver: user, post: @post).deliver
    end
  end
end
