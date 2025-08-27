class AddPriorityToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :priority, :string, default: 'Casual'
    
    # Add default values to existing records
    Task.update_all(priority: 'Casual')
  end
end 