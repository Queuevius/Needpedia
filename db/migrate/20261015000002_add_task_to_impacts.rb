class AddTaskToImpacts < ActiveRecord::Migration[6.0]
  def change
    # Reward rows must key on the task itself: title is mutable, so
    # "Completed: <title>" cannot be the idempotency key (rename -> reopen ->
    # complete minted duplicates; same-titled tasks collapsed into one row).
    add_reference :impacts, :task, null: true, index: true
    add_index :impacts, [:user_id, :task_id],
              unique: true,
              where: 'task_id IS NOT NULL',
              name: 'index_impacts_on_user_and_task'
  end
end
