import consumer from "./consumer"

consumer.subscriptions.create("MessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    let current_user_id = $('#user-chat-icon').data('user-id');
    if (current_user_id == data.sender_id) {
      $('.chatContainerScroll > li').last().after(data.sender_html);
    } else if (data.sender_blocked != true) {
      $('.chatContainerScroll > li').last().after(data.reciever_html);
      $('#chat_icon_' + data.reciever_id).addClass('unread-notificatios');
    }
    let reciever_convo = $('.conversation-' + data.reciever_id);
    let sender_convo = $('.conversation-' + data.sender_id);

    reciever_convo.after(data.reciever_conversation);
    sender_convo.after(data.sender_conversation);

    sender_convo.remove();
    reciever_convo.remove();
    console.log('data.conversation', data.conversation);


    $('.chatContainerScroll').animate({scrollTop: $('.chatContainerScroll .chat-hour:last').position().bottom});
  },
});
