class TokenAnsDebatesController < ApplicationController
  before_action :authenticate_user!
  include GibberishHelper

  # POST /token_ans_debates
  # POST /token_ans_debates.json
  def create
    @token_ans_debate = TokenAnsDebate.new(token_ans_debate_params)
    @post = Post.find(@token_ans_debate.post_id)
    if gibberish?(token_ans_debate_params[:content])
      flash[:alert] = "Invalid content."
      redirect_back(fallback_location: root_path)
    else
      respond_to do |format|
        if @token_ans_debate.save
          if @token_ans_debate.post_token.post_token_type == PostToken::TOKEN_TYPE_QUESTION
            format.html { redirect_to question_post_tokens_path(id: @token_ans_debate.post_token_id), notice: "Successfully created." }
          elsif @token_ans_debate.post_token.post_token_type == PostToken::TOKEN_TYPE_DEBATE && @token_ans_debate.debate_type.present?
            format.html { redirect_to debate_post_tokens_path(id: @token_ans_debate.post_token_id), notice: "Successfully created." }
          else
            format.html { redirect_to question_post_tokens_path(id: @token_ans_debate.post_token_id), notice: "Something went wrong." }
          end
          create_activity(@token_ans_debate, 'token.create')

          format.json { render :token_modal, post_token: @post_token }
        else
          flash[:alert] = @token_ans_debate.errors.full_messages.join(',')
          format.html { redirect_to question_post_tokens_path(id: @token_ans_debate.post_token_id) }
          format.json { render json: @token_ans_debate.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def token_ans_debate_params
    params.require(:token_ans_debate).permit(:content, :post_id, :user_id, :debate_type, :post_token_id)
  end

  def create_activity(gig, event)
    ActivityService.new(object: gig, event: event, owner: current_user, ip: request.remote_ip).call
  end
end
