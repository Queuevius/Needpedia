module MasterAdmin
  class ChatThreadsController < MasterAdmin::ApplicationController
    def index
      @threads = ChatThread.includes(:user, :guest, :chat_messages)
                           .order(created_at: :desc)

      if params[:search].present?
        term = "%#{params[:search]}%"
        @threads = @threads.joins("LEFT JOIN users ON users.id = chat_threads.user_id")
                           .joins("LEFT JOIN guests ON guests.id = chat_threads.guest_id")
                           .where(
                             "title ILIKE ? OR last_message ILIKE ? OR users.email ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR guests.uuid ILIKE ?",
                             term, term, term, term, term, term
                           )
      end

      if params[:user_id].present?
        @threads = @threads.where(user_id: params[:user_id])
      end

      if params[:guest_id].present?
        @threads = @threads.where(guest_id: params[:guest_id])
      end

      if params[:date_from].present?
        @threads = @threads.where("chat_threads.created_at >= ?", params[:date_from].to_datetime)
      end

      if params[:date_to].present?
        @threads = @threads.where("chat_threads.created_at <= ?", params[:date_to].to_datetime.end_of_day)
      end

      if params[:assistant_name].present?
        @threads = @threads.where(assistant_name: params[:assistant_name])
      end

      @threads = @threads.page(params[:page]).per(25)
    end

    def show
      @thread = ChatThread.includes(:user, :guest, :chat_messages).find(params[:id])
      @messages = @thread.chat_messages.order(:created_at)
    end
  end
end
