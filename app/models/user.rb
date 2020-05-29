class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable

  after_create :add_default_credit

  has_person_name

  has_many :notifications, foreign_key: :recipient_id
  has_many :services
  has_many :posts, dependent: :destroy
  has_many :posted_gigs, class_name: 'Gig', dependent: :destroy

  has_many :transferred_transactions, class_name: 'Transaction', foreign_key: :actor_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :recipient_id

  has_many :user_gigs
  has_many :gigs, through: :user_gigs, dependent: :destroy

  def credit_hours
    active_gigs_amount = posted_gigs.where(status: Gig::GIG_STATUS_ACTIVE).sum(:amount)
    sum = (received_transactions&.sum(:amount) - transferred_transactions&.sum(:amount) - active_gigs_amount).round(1)
    sum.negative? ? 0 : sum
  end

  def add_default_credit
    TransactionService.new(actor: nil, recipient: self, gig: nil, amount: 1, type: Transaction::TRANSACTION_TYPE_DEFAULT).call
  end
end
