class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
