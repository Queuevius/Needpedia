class CreateUserAssistantDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :user_assistant_documents do |t|
      t.string :title
      t.text :description
      t.text :change_log
      t.integer :user_id
      t.string :file_type

      t.timestamps
    end
  end
end
