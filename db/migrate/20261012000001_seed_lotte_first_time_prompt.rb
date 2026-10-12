class SeedLotteFirstTimePrompt < ActiveRecord::Migration[6.0]
  def up
    # Tests create/delete their own prompt rows; a committed seed would
    # break version-number assertions in ai_prompt_test.rb.
    return if Rails.env.test?

    execute <<~SQL.squish
      INSERT INTO ai_prompts (ai_type, description, version, active, created_at, updated_at)
      SELECT 'LotteFirstTime',
             'Hi, I''m Lotte — your AI librarian. This is your first time here, so here''s the deal: ask me anything about Needpedia, or pick one of the suggestions below. I can help you search ideas, navigate subjects and problems, or summarize the page you''re on.',
             1, TRUE, NOW(), NOW()
      WHERE NOT EXISTS (SELECT 1 FROM ai_prompts WHERE ai_type = 'LotteFirstTime')
    SQL
  end

  def down
    # Data seed — intentionally not reversible.
  end
end
