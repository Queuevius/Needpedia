class AddIpToActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :ip, :string
  end
end
