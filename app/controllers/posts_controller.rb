class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_type, only: [:index, :new, :problems, :proposals, :ideas]
  before_action :set_area, only: [:proposals, :problems, :ideas]

  # GET /posts
  # GET /posts.json
  # Area posts
  def index
    @posts = Post.area_posts
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

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @area_id = params[:area_id]
    @problem_id = params[:problem_id]
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  def set_area
    @post = Post.find(params[:post_id])
  end

  def set_type
    @type = params[:post_type] || Post::POST_TYPE_AREA
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :content, :user_id, :post_type, :area_id, :problem_id)
  end
end
