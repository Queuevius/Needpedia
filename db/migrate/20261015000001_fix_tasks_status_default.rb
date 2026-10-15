class FixTasksStatusDefault < ActiveRecord::Migration[6.0]
  def up
    change_column_default :tasks, :status, from: 'Casual', to: 'Available Tasks'
    # Data-fix: 'Casual' was never a valid status (validation rejects it), so
    # any rows carrying it were created around the broken default. Runs here so
    # production gets it at deploy-time db:migrate; dev DB is never migrated
    # locally (repo rule), test env applies this via maintain_test_schema.
    execute "UPDATE tasks SET status = 'Available Tasks' WHERE status = 'Casual'"
    # Title presence validation lands in this release; keep legacy blank-title
    # rows editable (status/assignee PATCHes run full validations).
    execute "UPDATE tasks SET title = '(untitled)' WHERE title IS NULL OR btrim(title) = ''"
  end

  def down
    change_column_default :tasks, :status, from: 'Available Tasks', to: 'Casual'
  end
end
