class AddCheckBackDateToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :check_back_date, :date
  end
end
