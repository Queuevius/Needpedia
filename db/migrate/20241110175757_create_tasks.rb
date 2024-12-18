class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.belongs_to :group
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
