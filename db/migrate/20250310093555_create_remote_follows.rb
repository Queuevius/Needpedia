class CreateRemoteFollows < ActiveRecord::Migration[6.0]
  def change
    create_table :remote_follows do |t|
      t.string :actor_id
      t.references :user, null: false, foreign_key: true
      t.string :follower_url
      t.string :follower_inbox
      t.string :status
      t.string :target_url

      t.timestamps
    end
  end
end
