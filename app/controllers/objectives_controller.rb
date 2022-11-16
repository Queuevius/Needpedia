class ObjectivesController < ApplicationController

  def create
    @post = Post.find(params[:post_id])
    @objective = @post.objectives.create(objective_params)
    # respond_to do |format|
      if @objective.save!
        # format.js
         redirect_to @post, notice: 'Objective was successfully created.'
        create_activity(@post, 'post.commented_on')
      else
        flash[:alert] = @objective.errors.full_messages.join(',')
      end
    # end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_objective
    @objective = Objective.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def objective_params
    params.require(:objective).permit(:content, :user_id, :post_id)
  end

  def create_activity(post, event)
    ActivityService.new(object: post, event: event, owner: current_user).call
  end
end
