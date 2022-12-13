class RelatedContentsController < ApplicationController
  def edit
    @post = Post.find(params[:post_id])
    @content = @post.related_contents.find(params[:id])
  end

  def new
    @post = Post.find(params[:post_id])
    @content = @post.related_contents.new(parent_id: params[:parent_id])
  end

  def create
    @post = Post.find(related_content_params[:post_id])
    @related_content = @post.related_contents.create(related_content_params)
    respond_to do |format|
      if @related_content.save
        format.js
        format.html {redirect_to post_path(@post), notice: 'Related Content was successfully created.'}
        format.json {render :show, status: :created, location: @related_content}
      else
        flash[:alert] = @related_content.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @related_content.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    @content = RelatedContent.find(params[:id])
    @post = @content.post

    respond_to do |format|
      if @content.update(related_content_params)
        format.html {redirect_to post_path(@post), notice: 'Related Content was successfully updated.'}
        format.json {render :edit, status: :created, location: @content}
      else
        flash[:alert] = @content.errors.full_messages.join(',')
        format.html {redirect_to post_path(@post)}
        format.json {render json: @content.errors, status: :unprocessable_entity}
      end
    end
  end

  def remove_content
    @related_content = RelatedContent.find(params[:related_content_id])
    @post = @related_content.post
    if @related_content.destroy
      redirect_to post_path(@post), notice: 'Related Content successfully deleted.'
    end
  end

  private

  def set_objective
    @objective = RelatedContent.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def related_content_params
    params.require(:related_content).permit(:body, :user_id, :parent_id, :post_id)
  end
end
