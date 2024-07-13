class CreateUserTutorials < ActiveRecord::Migration[6.0]
  def change
    create_table :user_tutorials do |t|
      t.string :link
      t.text :content
      t.boolean :viewed, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
