class UserMailer < ApplicationMailer
  WEB_DOMAIN = ENV['RAILS_ENV'] == 'development' ? 'http://localhost:3000' : 'https://needpedia.org'
  def send_message_email(receiver:, sender:)
    @receiver = receiver
    @sender = sender
    mail(to: @receiver.email, subject: 'New Message')
  end

  def send_tracking_email(actor:, receiver:, post:)
    @actor = actor
    @receiver = receiver
    @post = post
    @url = "#{WEB_DOMAIN}/posts/#{@post.id}"
    mail(to: @receiver.email, subject: 'Notification')
  end

  def wiki_post_added_email(actor:, receiver:, post:)
    @actor = actor
    @receiver = receiver
    @post = post
    @url = "#{WEB_DOMAIN}/posts/#{@post.id}"
    mail(to: @receiver.email, subject: 'Notification')
  end

  def layer_added_or_updated_email(event_message:, receiver:, post:)
    @event_message = event_message
    @receiver = receiver
    @post = post
    @url = "#{WEB_DOMAIN}/posts/#{@post.id}"
    mail(to: @receiver.email, subject: 'Notification')
  end

  def send_daily_email(receiver, posts, messages)
    return if posts.blank? && messages.blank?

    @receiver = receiver
    @posts = posts
    @messages = messages
    @domain = WEB_DOMAIN
    mail(to: @receiver.email, subject: "Today's Notifications")
  end
end
