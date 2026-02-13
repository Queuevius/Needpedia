require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create(username: 'user1', email: 'user1@example.com', password: 'password')
    @user2 = User.create(username: 'user2', email: 'user2@example.com', password: 'password')
    @gig = Gig.create(title: 'Sample Gig', user: @user1)
  end

  test 'should be valid with valid attributes' do
    transaction = Transaction.new(recipient: @user2, actor: @user1, amount: 100, transaction_type: Transaction::TRANSACTION_TYPE_GIG)
    assert transaction.valid?
  end

  test 'should not be valid without a recipient' do
    transaction = Transaction.new(actor: @user1, amount: 100, transaction_type: Transaction::TRANSACTION_TYPE_GIG)
    assert_not transaction.valid?
  end

  test 'should not be valid without an amount' do
    transaction = Transaction.new(recipient: @user2, actor: @user1, transaction_type: Transaction::TRANSACTION_TYPE_GIG)
    assert_not transaction.valid?
  end

  test 'should not be valid without a transaction_type' do
    transaction = Transaction.new(recipient: @user2, actor: @user1, amount: 100)
    assert_not transaction.valid?
  end

  test 'should belong to a recipient' do
    association = Transaction.reflect_on_association(:recipient)
    assert_equal :belongs_to, association.macro
    assert_equal User, association.class_name
  end

  test 'should belong to an actor with optional: true' do
    association = Transaction.reflect_on_association(:actor)
    assert_equal :belongs_to, association.macro
    assert_equal User, association.class_name
    assert association.options[:optional]
  end

  test 'should belong to a gig with optional: true' do
    association = Transaction.reflect_on_association(:gig)
    assert_equal :belongs_to, association.macro
    assert_equal Gig, association.class_name
    assert association.options[:optional]
  end

  test 'should have TRANSACTION_TYPES constant' do
    assert_equal ['gig', 'default', 'admin', 'delete'], Transaction::TRANSACTION_TYPES
  end
end
