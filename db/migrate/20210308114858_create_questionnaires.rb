class CreateQuestionnaires < ActiveRecord::Migration[6.0]
  def change
    create_table :questionnaires do |t|
      t.text :title
      t.boolean :active

      t.timestamps
    end
  end
end
