module Webhooks
  class PostsController < ApplicationController

    skip_before_action :verify_authenticity_token

    def create
      unless WebhookSetting.webhook_receiving_enabled?
        render json: { error: 'receiving_disabled' }, status: :service_unavailable and return
      end
      # Normalize header retrieval across Rack variants
      secret = request.headers['X-Webhook-Secret'] ||
               request.headers['HTTP_X_WEBHOOK_SECRET'] ||
               request.headers['x-webhook-secret'] ||
               params[:secret]
      unless secret.present?
        render json: { error: 'unauthorized' }, status: :unauthorized and return
      end
      unless secret == ENV['WEBHOOK_SECRET']
        render json: { error: 'unauthorized' }, status: :unauthorized and return
      end


      payload = params.permit(
        :title,
        :content,
        :post_type,
        :user_id,
        :subject_id,
        :problem_id,
        :lat,
        :long,
        :posted_to_id,
        :geo_maxing,
        :group_id,
        :created_at,
        :updated_at,
        tags: [],
        resource_tags: []
      )

      post = Post.new(
        title: payload[:title],
        post_type: payload[:post_type],
        user_id: payload[:user_id],
        subject_id: payload[:subject_id],
        problem_id: payload[:problem_id],
        lat: payload[:lat],
        long: payload[:long],
        posted_to_id: payload[:posted_to_id],
        geo_maxing: payload[:geo_maxing],
        group_id: payload[:group_id]
      )


      post.tag_list = payload[:tags] if payload[:tags].present?
      post.resource_tag_list = payload[:resource_tags] if payload[:resource_tags].present?
      post.content = payload[:content] if payload[:content].present?
      post.created_at = payload[:created_at] if payload[:created_at].present?
      post.updated_at = payload[:updated_at] if payload[:updated_at].present?

      if post.save
        render json: { id: post.id, url: post.url }, status: :created
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end


