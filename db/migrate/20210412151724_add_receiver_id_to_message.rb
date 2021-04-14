class AddReceiverIdToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :receiver_id, :integer
  end
end
