module Api
  module V1
    class PostVersionsController < ApplicationController
      before_action :authenticate_token!

      def active
        post = Post.find(params[:post_id])
        version = post.post_versions.where(active: true).last
        render json: { version_id: version&.id, version_created_at: version&.created_at }
      end

      private

      def authenticate_token!
        token = request.headers['Authorization']&.sub(/^Bearer /, '') || request.headers['token']
        @current_user = User.find_by(uuid: token)
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end
    end
  end
end
