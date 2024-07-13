class ObjectivesController < ApplicationController

  def new
    @post = Post.find(params[:post_id])
    @objective = @post.objectives.new(parent_id: params[:parent_id])
  end

  def edit
    @post = Post.find(params[:post_id])
    @objective = @post.objectives.find(params[:id])
  end

  def create
    @post = Post.find(objective_params[:post_id])
    @objective = @post.objectives.new(objective_params)
    respond_to do |format|
      content = objective_params[:body]
      banned_term = BannedTerm.last
      if banned_term.present?
        banned_terms = banned_term.term
        checker = TermCheckerService.new(content, banned_terms)
        response = checker.content_contains_banned_term
        if response.present?
          @found_term = response
          render :new
          return
        end
      end
      if @objective.save
        format.js
        format.html {redirect_to post_path(@post), notice: 'Objective was successfully created.'}
        format.json {render :show, status: :created, location: @objective}
      else
        flash[:alert] = @objective.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @objective.errors, status: :unprocessable_entity}
      end
    end
  end

  def remove_objective
    @objective = Objective.find(params[:objective_id])
    @post = @objective.post
    if @objective.destroy
      redirect_to post_path(@post), notice: 'Objective successfully deleted.'
    end
  end

  def update
    @objective = Objective.find(params[:id])
    @post = @objective.post

    respond_to do |format|
      content = objective_params[:body]
      banned_term = BannedTerm.last
      if banned_term.present?
        banned_terms = banned_term.term
        checker = TermCheckerService.new(content, banned_terms)
        response = checker.content_contains_banned_term
        if response.present?
          render :edit
          @found_term = response
          return
        end
      end
      if @objective.update(objective_params)
        format.html {redirect_to post_path(@post), notice: 'Objective was successfully updated.'}
        format.json {render :edit, status: :created, location: @objective}
      else
        flash[:alert] = @objective.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @objective.errors, status: :unprocessable_entity}
      end
    end
  end

  private

  def objective_params
    params.require(:objective).permit(:body, :user_id, :post_id, :parent_id)
  end
end
