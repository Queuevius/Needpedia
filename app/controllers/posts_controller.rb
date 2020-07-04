class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_type, only: [:index, :new, :problems, :proposals, :ideas, :layers]
  before_action :set_area, only: [:proposals, :problems, :ideas, :layers]

  # GET /posts
  # GET /posts.json
  # Area posts
  def index
    if params[:tag]
      @posts = Post.tagged_with(params[:tag])
    else
      @posts = Post.posts_feed
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
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
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
    @posts = @q.result(distinct: true)
  end

  def modal
    @post = Post.new()
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find_by_id(params[:id])
  end

  def set_area
    @post = Post.find_by_id(params[:post_id])
  end

  def set_type
    @type = params[:post_type] || Post::POST_TYPE_AREA
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :content, :user_id, :post_type, :area_id, :problem_id, :post_id, :tag_list)
  end
end
