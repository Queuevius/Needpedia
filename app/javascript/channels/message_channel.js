import consumer from "./consumer"

consumer.subscriptions.create("MessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  // document.getElementById("messages").innerHTML += data.html
    $('.chatContainerScroll > li').last().after(data.html);
    let chat_icon = $('#chat_icon_' + data.reciever_id);
    if (chat_icon.length) {
        $('#chat_icon_' + data.reciever_id).addClass('unread-notificatios');
    } else {
        $.ajax({
            url: data.path,
            type: "PATCH",
            dataType: "JSON"
        });
    }
  }
});
