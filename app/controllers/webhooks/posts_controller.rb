module Webhooks
  class PostsController < ApplicationController
    resource_description do
      name 'Webhooks - Posts'
      short 'Incoming webhook to create posts'
      api_versions 'v1'
    end
    skip_before_action :verify_authenticity_token

    api :POST, '/webhooks/posts', 'Create a post via incoming webhook'
    header 'X-Webhook-Secret', 'Shared secret for authentication', required: true
    param :title, String, desc: 'Post title', required: true
    param :content, String, desc: 'Post content (text or HTML)'
    param :post_type, String, desc: 'Type of the post (e.g., idea, problem, note)'
    param :user_id, Integer, desc: 'User ID for the post creator', required: true
    param :subject_id, Integer, desc: 'Optional subject ID'
    param :problem_id, Integer, desc: 'Optional problem ID'
    param :lat, Float, desc: 'Latitude'
    param :long, Float, desc: 'Longitude'
    param :posted_to_id, Integer, desc: 'Destination/posted_to ID'
    param :geo_maxing, [TrueClass, FalseClass], desc: 'Geo-maxing flag'
    param :group_id, Integer, desc: 'Group ID'
    param :tags, Array, of: String, desc: 'List of tags'
    param :resource_tags, Array, of: String, desc: 'List of resource tags'
    param :created_at, String, desc: 'ISO8601 timestamp to override creation time'
    param :updated_at, String, desc: 'ISO8601 timestamp to override updated time'
    error code: 401, desc: 'Unauthorized (missing or invalid secret)'
    error code: 422, desc: 'Validation errors'
    error code: 503, desc: 'Receiving disabled by admin settings'
    example <<-EOS
    Request:
      POST /webhooks/posts
      Headers: { "X-Webhook-Secret": "<secret>" }
      Body:
      {
        "title": "Example from Webhook",
        "content": "Hello from an external system",
        "post_type": "idea",
        "user_id": 1,
        "tags": ["integration", "external"]
      }

    Success (201):
      { "id": 42, "url": "https://needpedia.org/posts/42" }
    EOS
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


