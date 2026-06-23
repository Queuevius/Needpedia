class CreateAiPrompts < ActiveRecord::Migration[6.0]
  def change
    create_table :ai_prompts do |t|
      t.string :ai_type
      t.text :description
      t.integer :version
      t.boolean :active

      t.timestamps
    end

    add_index :ai_prompts, :ai_type
    add_index :ai_prompts, :version
    add_index :ai_prompts, :active
    add_index :ai_prompts, [:ai_type, :version], unique: true
    add_index :ai_prompts, :ai_type,
              unique: true,
              where: "active = TRUE",
              name: "index_ai_prompts_on_ai_type_active"
  end
end
