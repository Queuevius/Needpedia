class FederatedPostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @federated_posts = fetch_followed_federated_posts
    @notifications = current_user.notifications
                         .where(action: Notification::NOTIFICATION_TYPE_ACTIVITYPUB_POST_SHARED)
                         .includes(:notifiable, :from_user)
                         .order(created_at: :desc)
                         .page(params[:notifications_page])
                         .per(10)
  end


  private


  def fetch_followed_federated_posts
    followed_accounts = RemoteFollow.where(user_id: current_user.id, status: RemoteFollow::ACCEPTED)
    all_followed_posts = []

    followed_accounts.each do |follow|
      actor_id = follow.actor_id

      if actor_id.present?
        puts "Fetching posts for actor: #{actor_id}"
          posts = FederatedPostsFetcher.fetch_user_posts_from_actor_id(actor_id) # Using the fetcher class
        all_followed_posts.concat(posts)
      else
        puts "Warning: Missing actor_id for follow ID #{follow.id}"
      end
    end

    # You might want to sort these posts as well
    all_followed_posts.sort_by { |post| DateTime.parse(post['created_at']) }.reverse
  end
end