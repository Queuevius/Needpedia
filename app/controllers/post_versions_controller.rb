class PostVersionsController < ApplicationController
  def restore
    post = Post.find(params[:post_id])
    version = post.post_versions.find(params[:id])

    post.post_versions.where(active: true).update_all(active: false)

    version.update!(restored_by_id: current_user.id, active: true)
    post.update!(content: version.content)

    redirect_to post, notice: "Post reverted successfully."
  end


  def request_delete
    version = PostVersion.find(params[:id])

    deletion_request = DeletionRequest.new(post_version: version, user: current_user, reason: params[:reason])

    if deletion_request.save
      flash[:notice] = "Request was created successfully"
      redirect_to request.referrer
    else
      render json: {success: false, error: "Failed to create the deletion request"}
    end
  end

end
