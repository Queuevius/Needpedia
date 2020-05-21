class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def accept
    begin
      recipient_id = params.require(:recipient_id)
      gig_id = params.require(:gig_id)
      recipient = User.find(recipient_id)
      gig = Gig.find(gig_id)
      amount = gig.amount

      if not_allowed?(gig, recipient) || gig.user == current_user
        flash[:alert] = 'This Gig can not be accepted.'
        redirect_to gig_path(gig) and return
      end

      ts = TransactionService.new(actor: recipient, recipient: current_user, gig: gig, amount: amount, type: Transaction::TRANSACTION_TYPE_GIG)
      if ts.call
        gig.update!(status: Gig::GIG_STATUS_AWARDED)
        flash[:notice] = 'Gig Accepted successfully...'
      else
        flash[:alert] = 'Your request could not be completed, please try again.'
      end
    rescue StandardError => e
      flash[:alert] = "An Error occurred: #{e}"
    end
    redirect_to gig_path(gig)
  end

  def award
    @gig = Gig.find(params[:gig_id])
    @transaction = Transaction.new
    @users = User.all.where("id != ?", current_user.id)
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
      if ts.call
        gig.update!(status: Gig::GIG_STATUS_AWARDED)
        flash[:notice] = 'Gig Accepted successfully...'
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
