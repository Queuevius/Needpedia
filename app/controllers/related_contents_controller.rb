class RelatedContentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @related_content = @post.related_contents.create(related_content_params)
    if @related_content.save!
      redirect_to @post, notice: 'Content was successfully created.'
    else
      flash[:alert] = @objective.errors.full_messages.join(',')
    end
  end
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_objective
    @objective = RelatedContent.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def related_content_params
    params.require(:related_content).permit(:content, :user_id, :post_id)
  end
end
