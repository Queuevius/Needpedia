class PostsController < ApplicationController
  before_action :check_account_status, only: [:update, :create, :edit, :new]
  before_action :authenticate_user!, only: [:new, :update, :create, :edit]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_type, only: [:index, :new, :problems, :ideas, :layers]
  before_action :set_area, only: [:problems, :ideas, :layers, :track_post]
  before_action :set_user, only: [:new, :have, :want]
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
    q = { user_first_name_cont: '' }
    redirect_to search_result_posts_path(q: q, post_type: post_type, sorted_by: sorted_by, access_type: access_type, subject_id: @post.id, subject: @post.title)
  end

  def ideas
    post_type = 'idea'
    sorted_by = 'Highest-Rated'
    access_type = 'Public'
    q = { user_first_name_cont: '' }
    redirect_to search_result_posts_path(q: q, post_type: post_type, sorted_by: sorted_by, access_type: access_type, problem_id: @post.id, problem: @post.title, subject: @post.parent_subject.title)
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

  def have
    posts = @user.posts.where(post_type: Post::POST_TYPE_HAVE).order('created_at desc')
    @posts = Kaminari.paginate_array(posts).page(params[:page]).per 10
    respond_to do |format|
      format.html
      format.js
    end
  end

  def want
    posts = @user.posts.where(post_type: Post::POST_TYPE_WANT).order('created_at desc')
    @posts = Kaminari.paginate_array(posts).page(params[:page]).per 10
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @comment = Comment.new(parent_id: params[:parent_id])
    @comments = @post.comments.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(12).order('comments.created_at DESC')
  end

  # GET /posts/new
  def new
    @subject_title = params[:subject_title]
    @problem_title = params[:problem_title]
    @idea_title = params[:idea_title]
    if params[:post] && params[:post][:from_feed]
      if [Post::POST_TYPE_PROBLEM].include?(@type)
        @subject_id = Post::GENERAL_AREA
      elsif @type == Post::POST_TYPE_IDEA
        @problem_id = Post::GENERAL_PROBLEM
      end
    end

    # Todo - for now the tag functionality is disabled, I am leaving this code
    # for a while but should be eventually removed if it was'nt required anymore.
    post_service = PostsService.new(@subject_title, @problem_title, @idea_title, @type, params[:subject_id], params[:problem_id], params[:post_id])
    new_post = post_service.new_post
    @post = new_post[:post]
    @subject_id = new_post[:subject_id]
    @problem_id = new_post[:problem_id]
    @post_id = new_post[:post_id]
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
        offsite_notification(@post)
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
      @open_advance_filters = @access_type.present? || @resource_tags.present? || @location_tags.present? || @problem.present? || @subject.present? || @idea.present? ? true : false
    end
  end

  def track_post
    begin
      tracking_post = current_user.tracking_posts.where(post_id: @post.id)
      if tracking_post.present?
        settings = NotificationSetting.where(user_id: current_user.id, post_id: @post.id)
        tracking_post.destroy_all
        settings.destroy_all if settings.present?
        flash[:notice] = 'You have DeActivated Tracking for this Post.'
      else
        UserPost.create!(user_id: current_user.id, post_id: @post.id, post_type: @post.post_type)
        edit_post = params[:edit_post]
        expert_layer = params[:expert_layer]
        related_wiki_post = params[:related_wiki_post]
        NotificationSetting.create(user_id: current_user.id, post_id: @post.id, edit_post: edit_post, expert_layer: expert_layer, related_wiki_post: related_wiki_post)
        flash[:notice] = 'You have activated Tracking for this Post.'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_back(fallback_location: post_path(@post))
  end

  def modal
    @post = Post.new
  end

  def map
    @post = Post.find(params[:post_id])
    @geo_maxing_posts = Post.geo_maxing_posts
  end

  def geo_maxing_posts
    @geo_maxing_posts = Post.geo_maxing_posts
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    if params[:uuid].present?
      @posted_to = User.find_by(uuid: params[:uuid])
      @user = @posted_to
      @uuid = params[:uuid]
    else
      @user = current_user
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
    params.require(:post).permit(:title, :content, :user_id, :post_type, :subject_id, :problem_id, :private, :curated, :post_id, :posted_to_id, :tag_list, :resource_tag_list, :geo_maxing, :lat, :long, images: [])
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end

  def offsite_notification(post)
    settings = post.notification_settings.where(edit_post: true)
    return unless settings.present?

    settings.collect(&:user).each do |user|
      if post.post_type.in?(Post::CORE_POST_TYPES)
        UserMailer.send_tracking_email(actor: current_user, receiver: user, post: @post).deliver
      elsif post.post_type == Post::POST_TYPE_LAYER
        UserMailer.layer_added_or_updated_email(event_message: 'A Post has been edited', receiver: user, post: @post).deliver
      end
    end
  end

  def send_update_email
    @post.users.each do |user|
      next if user.all_notifications? || user.daily_notifications? || !user.track_notifications?

      UserMailer.send_tracking_email(actor: current_user, receiver: user, post: @post).deliver
    end
  end

  def check_account_status
    redirect_to root_path, alert: "Can't perform this action right now sorry for the inconvenience." and return if Setting.posts_freezed
  end
end
