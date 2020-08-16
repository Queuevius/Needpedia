class PostTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post_token, only: [:update, :destroy]

  # POST /post_tokens
  # POST /post_tokens.json
  def create
    @post_token = PostToken.new(post_token_params)
    @post = Post.find(@post_token.post_id)

    respond_to do |format|
      if @post_token.save
        format.json { render :token_modal, post_token: @post_token }
      else
        flash[:alert] = @post_token.errors.full_messages.join(',')
        format.json { render json: @post_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_tokens/1
  # PATCH/PUT /post_tokens/1.json
  def update
    @post = Post.find(@post_token.post_id)
    @post_token.update(token_params)
    respond_to do |format|
      format.js
    end
  end

  # DELETE /post_tokens/1
  # DELETE /post_tokens/1.json
  # def destroy
  #   # id is here post id
  #   @post = Post.find(params[:id])
  #   @token = @post.token.where(user_id: current_user.id).last
  #   if @flag.blank?
  #     flash[:notice] = 'Not flagged'
  #     redirect_to post_path(@post) and return
  #   end
  #   if @post.destroy
  #     flash[:notice] = 'You have unflagged this Post'
  #   else
  #     flash[:notice] = 'Some thing went wrong'
  #   end
  #   redirect_to post_path(@post)
  # end

  # GET /post_tokens/token_modal
  def token_modal
    @post = Post.find_by_id(params[:post_id])
    @post_token = PostToken.find_by_id(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def note
    @post_token = PostToken.find_by_id(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def debate
    @token_ans_debate = TokenAnsDebate.new
    @post_token = PostToken.find_by_id(params[:id])
    @for_arguments = @post_token.token_ans_debate.where(debate_type: TokenAnsDebate::DEBATE_TYPE_FOR).left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
    @other_arguments = @post_token.token_ans_debate.where(debate_type: TokenAnsDebate::DEBATE_TYPE_NEUTRAL).left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
    @against_arguments = @post_token.token_ans_debate.where(debate_type: TokenAnsDebate::DEBATE_TYPE_AGAINST).left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
    respond_to do |format|
      format.html
    end
  end

  def question
    @token_ans_debate = TokenAnsDebate.new
    @post_token = PostToken.find_by_id(params[:id])
    @answers = @post_token.token_ans_debate.left_joins(:likes).group(:id).order('COUNT(likes.id) DESC')
    respond_to do |format|
      format.html
    end
  end

  private

  def set_post_token
    @post_token = PostToken.find_by_id(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_token_params
    params.permit(:content, :post_id, :post_token_type, :user_id)
  end

  def token_params
    params.require(:post_token).permit(:content)
  end
end
