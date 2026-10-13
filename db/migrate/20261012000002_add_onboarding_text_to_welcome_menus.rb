class AddOnboardingTextToWelcomeMenus < ActiveRecord::Migration[6.0]
  def change
    add_column :welcome_menus, :onboarding_text, :text
  end
end
