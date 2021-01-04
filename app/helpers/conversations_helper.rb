module ConversationsHelper
  def chat_user(chat)
    chat.users.where.not(id: current_user.id).last
  end
end
