class CreateBlockedIps < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_ips do |t|
      t.string :ip

      t.timestamps
    end
  end
end
