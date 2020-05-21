class TransactionService
  def initialize(actor:, recipient:, type:, amount:, gig:)
    @actor = actor
    @recipient = recipient
    @type = type
    @amount = amount
    @gig = gig
  end

  def call
    Transaction.create!(
      actor: @actor,
      recipient: @recipient,
      transaction_type: @type,
      amount: @amount,
      gig_id: @gig&.id
    )
  end
end
