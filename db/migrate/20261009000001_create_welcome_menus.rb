class CreateWelcomeMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :welcome_menus do |t|
      t.text :content

      t.timestamps
    end
  end
end
