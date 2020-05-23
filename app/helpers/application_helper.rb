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
    count = user.notifications.unread.count
    'unread-notificatios' if count.positive?
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
end
