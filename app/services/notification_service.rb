class NotificationService
  def initialize(post, current_user)
    @post = post
    @current_user = current_user
  end

  attr_accessor :post, :current_user

  def send
    settings = if post.post_type == Post::POST_TYPE_LAYER
                 post.parent_post.notification_settings.where(expert_layer: true)
               elsif post.post_type == Post::POST_TYPE_PROBLEM
                 post.parent_subject.notification_settings.where(related_wiki_post: true)
               elsif post.post_type == Post::POST_TYPE_IDEA
                 post.problem.notification_settings.where(related_wiki_post: true)
               else
                 post.notification_settings.where(expert_layer: true)
               end

    return unless settings.present?

    settings.collect(&:user).each do |user|
      if post.post_type.in?(Post::CORE_POST_TYPES)
        UserMailer.wiki_post_added_email(actor: current_user, receiver: user, post: post).deliver
      elsif post.post_type == Post::POST_TYPE_LAYER
        UserMailer.layer_added_or_updated_email(event_message: 'A Layer Post has been added', receiver: user, post: post).deliver
      end
    end
  end
end