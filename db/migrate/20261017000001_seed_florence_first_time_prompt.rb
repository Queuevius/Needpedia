class SeedFlorenceFirstTimePrompt < ActiveRecord::Migration[6.0]
  def up
    # Tests create/delete their own prompt rows; a committed seed would
    # break version-number assertions in ai_prompt_test.rb.
    return if Rails.env.test?

    execute <<~SQL.squish
      INSERT INTO ai_prompts (ai_type, description, version, active, created_at, updated_at)
      SELECT 'FlorenceFirstTime',
             'Hi, I''m Florence — your Needpedia greeter. This is your first time here, so here''s the deal: ask me anything about the site, or tell me your name and email and I''ll set up a free account for you. I can also point you to ideas, subjects, and problems worth exploring.',
             1, TRUE, NOW(), NOW()
      WHERE NOT EXISTS (SELECT 1 FROM ai_prompts WHERE ai_type = 'FlorenceFirstTime')
    SQL
  end

  def down
    # Data seed — intentionally not reversible.
  end
end
