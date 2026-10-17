class AddButtonLabelsToWelcomeMenus < ActiveRecord::Migration[6.0]
  def change
    add_column :welcome_menus, :button_no_ai_label, :string
    add_column :welcome_menus, :button_ai_label, :string
  end
end
