class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.bigint :recipient_id
      t.bigint :actor_id
      t.string :transaction_type
      t.float :amount
      t.bigint :gig_id

      t.timestamps
    end
  end
end
