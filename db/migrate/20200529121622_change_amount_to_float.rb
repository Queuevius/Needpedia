class ChangeAmountToFloat < ActiveRecord::Migration[6.0]
  def change
    change_column :gigs, :amount, :float
  end
end
