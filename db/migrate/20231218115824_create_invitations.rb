class CreateInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :invitations do |t|
      t.references :user, foreign_key: true
      t.references :group, foreign_key:

      t.timestamps
    end
  end
end
