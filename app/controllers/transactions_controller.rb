class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def award
    @gig = Gig.find(params[:gig_id])
    @transaction = Transaction.new
    @users = @gig.users
  end

  # this is for the awarding a gig to a user
  def create
    begin
      recipient_id = params.require(:transaction)[:recipient_id]
      gig_id = params.require(:transaction)[:gig_id]
      recipient = User.find(recipient_id)
      gig = Gig.find(gig_id)
      amount = gig.amount

      if not_allowed?(gig, recipient)
        flash[:alert] = 'This Gig can not be awarded.'
        redirect_to gig_path(gig) and return
      end
      ts = TransactionService.new(actor: current_user, recipient: recipient, gig: gig, amount: amount, type: Transaction::TRANSACTION_TYPE_GIG)
      gig.status = Gig::GIG_STATUS_AWARDED
      if ts.call && gig.save!(validate: false)
        Notification.post(
          from: current_user,
          notifiable: current_user,
          to: recipient, action: Notification::NOTIFICATION_TYPE_AWARDED
        )
        flash[:notice] = 'Gig Awarded successfully.'
      else
        flash[:alert] = 'Your request could not be completed, please try again.'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_to gig_path(gig)
  end

  private

  def not_allowed?(gig, recipient)
    gig.nil? || recipient.nil? || gig.credit_transaction.present?
  end
end
