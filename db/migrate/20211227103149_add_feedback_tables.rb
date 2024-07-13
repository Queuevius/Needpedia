class AddFeedbackTables < ActiveRecord::Migration[6.0]
  def change
    create_table :feedback_questions do |t|
      t.text :body
      t.timestamps
    end

    create_table :feedback_question_options do |t|
      t.text :body
      t.references:feedback_question, foreign_key: true, null: false
      t.timestamps
    end

    create_table :feedbacks do |t|
      t.references :user
      t.timestamps
    end

    create_table :feedback_responses do |t|
      t.references :feedback
      t.references :feedback_question
      t.references :feedback_question_option
      t.text :comment
      t.timestamps
    end
  end
end
