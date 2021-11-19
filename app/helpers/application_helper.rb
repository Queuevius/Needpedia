module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def post_type_color(type)
    {
      idea: "text-success",
      problem: "text-danger",
      area: "text-primary",
      proposal: "text-purple"
    }.stringify_keys[type.to_s] || type.to_s
  end

  def unread_notification(user)
    count = user&.notifications&.unread&.count
    'unread-notificatios' if count&.positive?
  end

  def unread_messages(user)
    blocked_user_ids = user.blocked_users.pluck(:block_user_id)
    count = user&.conversations.joins(:messages).where(messages: { read_at: nil }).where.not(messages: { user_id: blocked_user_ids.push(user.id) }).count
    'unread-notificatios' if count&.positive?
  end

  def unread_msg_in_navbar(conversation, user)
    blocked_user_ids = user.blocked_users.pluck(:block_user_id)
    count = conversation.messages.where(read_at: nil).where.not(user_id: blocked_user_ids.push(user.id)).count
    'unread-notificatios' if count&.positive?
  end

  def set_id_for_icon(user, params)
    if params[:controller] == 'conversations' && params['action'] == 'index' || params['action'] == 'show'
      'chat_icon'
    else
      "chat_icon_#{current_user.id}"
    end
  end

  def gig_status_text(gig)
    case gig.status
    when Gig::GIG_STATUS_PROGRESS
      gig.users.pluck(:first_name).join(', ') + (gig.users.count > 1 ? ' are currently working on this Gig' : ' is currently working on this Gig')
    when Gig::GIG_STATUS_ACTIVE
      'This Gig is currently Active and is available in Search'
    when Gig::GIG_STATUS_AWARDED
      'This Gig is awarded to ' + gig.credit_transaction.recipient.name
    when Gig::GIG_STATUS_DISABLE
      'This Gig has been disabled'
    end
  end

  def request_recieved?(id, uuid)
    result = false
    sender = User.find id
    reciever = current_user
    if uuid == reciever.uuid
      connection_request = ConnectionRequest.where(user_id: sender.id, to: uuid, status: 'pending')
      result = true if connection_request.present?
    end
    result
  end

  def voted?(argument)
    argument.likes.pluck(:user_id).include?(current_user.id) || argument.flags.pluck(:user_id).include?(current_user.id)
  end

  def post_token(post, user)
    PostToken.where(post_id: post.id, user_id: user.id).last
  end

  def post_comments(post)
    post.comments.where(parent_id: nil).page(params[:page].present? ? params[:page] : 1).per(5).order('comments.created_at DESC')
  end
end
