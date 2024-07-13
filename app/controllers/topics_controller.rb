class TopicsController < ApplicationController
  def new
    @group = Group.find(params[:group_id])
    @topic = @group.topics.new(parent_id: params[:parent_id])
  end

  def edit
    @group = Group.find(params[:group_id])
    @topic = @group.topics.find(params[:id])
  end

  def create
    @group = Group.find(topic_params[:group_id])

    @topic = @group.topics.new(topic_params)
    respond_to do |format|
      content = topic_params[:body]
      banned_term = BannedTerm.last
      if banned_term.present?
        banned_terms = banned_term.term
        checker = TermCheckerService.new(content, banned_terms)
        response = checker.content_contains_banned_term
        if response.present?
          @found_term = response
          return
        end
      end
      if @topic.save
        @topics = @group.topics.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(5).order('topics.created_at DESC')
        format.js
        format.html {redirect_to group_path(@group), notice: 'Topic was successfully created.'}
        format.json {render :show, status: :created, location: @topic}
      else
        flash[:alert] = @topic.errors.full_messages.join(',')
        format.html {redirect_to group_path(@group)}
        format.json {render json: @topic.errors, status: :unprocessable_entity}
      end
    end
  end

  def remove_topic
    @topic = Topic.find(params[:topic_id])
    @group = @topic.group
    if @topic.destroy
      redirect_to group_path(@group), notice: 'Topic successfully deleted.'
    end
  end

  def update
    @topic = Topic.find(params[:id])
    @group = @topic.group

    respond_to do |format|
      content = topic_params[:body]
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
      if @topic.update(topic_params)
        format.html {redirect_to group_path(@group), notice: 'Topic was successfully updated.'}
        format.json {render :edit, status: :created, location: @topic}
      else
        flash[:alert] = @topic.errors.full_messages.join(',')
        format.html {redirect_to group_path(@group)}
        format.json {render json: @topic.errors, status: :unprocessable_entity}
      end
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:body, :user_id, :group_id, :parent_id)
  end
end
