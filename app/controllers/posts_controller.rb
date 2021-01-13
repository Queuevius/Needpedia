class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :update, :create, :edit]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_type, only: [:index, :new, :problems, :proposals, :ideas, :layers]
  before_action :set_area, only: [:proposals, :problems, :ideas, :layers, :track_post]

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
    @posts = Post.problem_posts.where(area_id: @post.id)
  end

  def proposals
    @posts = Post.proposal_posts.where(area_id: @post.id)
  end

  def ideas
    @posts = Post.idea_posts.where(problem_id: @post.id)
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

  def all_proposals
    @posts = Post.proposal_posts
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
    @comment = Comment.new
  end

  # GET /posts/new
  def new
    @area_id = params[:area_id]
    @problem_id = params[:problem_id]
    @post_id = params[:post_id]
    if params[:post] && params[:post][:from_feed]
      if [Post::POST_TYPE_PROPOSAL, Post::POST_TYPE_PROBLEM].include?(@type)
        @area_id = Post::GENERAL_AREA
      elsif @type == Post::POST_TYPE_IDEA
        @problem_id = Post::GENERAL_PROBLEM
      else
      end
    end
    @post = Post.new(post_type: @type)
    @private_users = @post.private_users << current_user
  end

  # GET /posts/1/edit
  def edit
    @private_users = @post.private_users
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        # @post.clean_froala_link
        UserPrivatePost.create(post_id: @post.id, user_id: current_user&.id) if @post.post_type == Post::POST_TYPE_AREA
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
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_result
    @keywords = params[:q]
    @q = Post.ransack(@keywords)
    @u = User.ransack({ first_name_or_last_name_cont: @keywords[:title_cont] })
    @posts = @q.result(distinct: true)
    @users = @u.result(distinct: true)
  end

  def track_post
    begin
      tracking_post = current_user.tracking_posts.where(post_id: @post.id)
      if tracking_post.present?
        tracking_post.destroy_all
        flash[:notice] = 'You have DeActivated Tracking for this Post.'
      else
        UserPost.create!(user_id: current_user.id, post_id: @post.id, post_type: @post.post_type)
        flash[:notice] = 'You have activated Tracking for this Post.'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_back(fallback_location: post_path(@post))
  end

  def modal
    @post = Post.new()
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find_by_id(params[:id])
  end

  def create_private_users
    user_ids = params[:post][:user_ids]
    return unless user_ids.present?

    user_ids.each do |user|
      post = UserPrivatePost.where(post_id: @post.id, user_id: user.to_i)
      UserPrivatePost.create(post_id: @post.id, user_id: user.to_i) if post.blank?
    end
  end

  def set_area
    @post = Post.find_by_id(params[:post_id])
  end

  def set_type
    @type = params[:post_type] || Post::POST_TYPE_AREA
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :content, :user_id, :post_type, :area_id, :problem_id, :private, :post_id, :tag_list, images: [])
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end
end
