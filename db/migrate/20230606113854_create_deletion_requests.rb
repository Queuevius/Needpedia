class CreateDeletionRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :deletion_requests do |t|
      t.references :post_version, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reason

      t.timestamps
    end
  end
end
