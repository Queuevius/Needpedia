class TokenAnsDebatesController < ApplicationController
  before_action :authenticate_user!

  # POST /token_ans_debates
  # POST /token_ans_debates.json
  def create

    @token_ans_debate = TokenAnsDebate.new(token_ans_debate_params)
    @post = Post.find(@token_ans_debate.post_id)

    respond_to do |format|
      if @token_ans_debate.save

        if @token_ans_debate.debate_type.present?
          format.html { redirect_to debate_post_tokens_path(id: @token_ans_debate.post_token_id), notice: "Successfully created." }
        else
          format.html { redirect_to question_post_tokens_path(id: @token_ans_debate.post_token_id), notice: "Something went wrong." }
        end

        format.json { render :token_modal, post_token: @post_token }
      else
        flash[:alert] = @token_ans_debate.errors.full_messages.join(',')
        format.html { redirect_to question_post_tokens_path(id: @token_ans_debate.post_token_id) }
        format.json { render json: @token_ans_debate.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def token_ans_debate_params
    params.require(:token_ans_debate).permit(:content, :post_id, :user_id, :debate_type, :post_token_id)
  end
end
