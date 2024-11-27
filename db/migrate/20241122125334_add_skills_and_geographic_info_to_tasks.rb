class AddSkillsAndGeographicInfoToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :skills, :text, array: true, default: []
    add_column :tasks, :city, :string
    add_column :tasks, :status, :string, default: 'Casual', null: false
    add_column :tasks, :hours, :decimal, precision: 5, scale: 2, default: 1.0, null: false
  end
end
