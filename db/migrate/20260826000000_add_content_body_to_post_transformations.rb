class AddContentBodyToPostTransformations < ActiveRecord::Migration[6.0]
  def change
    add_column :post_transformations, :content_body, :text

    # Migrate any existing ActionText data to the new column
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE post_transformations
          SET content_body = (
            SELECT at.body::text
            FROM action_text_rich_texts at
            WHERE at.record_type = 'PostTransformation'
              AND at.record_id = post_transformations.id
              AND at.name = 'content'
            LIMIT 1
          )
          WHERE content_body IS NULL
        SQL
      end
    end
  end
end
