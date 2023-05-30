class CreateTutorials < ActiveRecord::Migration[6.0]
  def change
    create_table :tutorials do |t|
      t.string :link
      t.text :content
      t.boolean :show

      t.timestamps
    end
  end
end
