class AddAssigneeToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :assignee, null: true, foreign_key: { to_table: :users }
  end
end
