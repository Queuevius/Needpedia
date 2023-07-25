class InterestedUsersController < ApplicationController

  def new
    @post = Post.find(params[:post_id])
    @interested_user = @post.interested_users.new(parent_id: params[:parent_id])
  end


  def edit
    @post = Post.find(params[:post_id])
    @interested_user = InterestedUser.find(params[:id])
  end

  def create
    @post = Post.find(interested_user_params[:post_id])
    @interested_user = @post.interested_users.new(interested_user_params)

    respond_to do |format|
      content = interested_user_params[:content]
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
      if @interested_user.save
        format.js
        format.html {redirect_to post_path(@post), notice: 'Interested user was successfully created.'}
        format.json {render :show, status: :created, location: @interested_user}
      else
        flash[:alert] = @interested_user.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @interested_user.errors, status: :unprocessable_entity}
      end
    end
  end

  def remove_interested_user
    @interested_user = InterestedUser.find(params[:interested_user_id])
    @post = @interested_user.post
    if @interested_user.destroy
      redirect_to post_path(@post), notice: 'Interested User successfully deleted.'
    end
  end

  def update
    @interested_user = InterestedUser.find(params[:id])
    @post = @interested_user.post

    respond_to do |format|
      content = interested_user_params[:content]
      banned_term = BannedTerm.last
      if banned_term.present?
        banned_terms = banned_term.term
        checker = TermCheckerService.new(content, banned_terms)
        response = checker.content_contains_banned_term
        if response.present?
          @found_term = response
          render :edit
          return
        end
      end
      if @interested_user.update(interested_user_params)
        format.html {redirect_to post_path(@post), notice: 'Interested User was successfully updated.'}
        format.json {render :edit, status: :created, location: @interested_user}
      else
        flash[:alert] = @interested_user.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @interested_user.errors, status: :unprocessable_entity}
      end
    end
  end


  private

  def interested_user_params
    params.require(:interested_user).permit(:content, :user_id, :post_id, :parent_id)
  end
end
