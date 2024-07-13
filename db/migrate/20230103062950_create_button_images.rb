class CreateButtonImages < ActiveRecord::Migration[6.0]
  def change
    create_table :button_images do |t|
      t.string :name
      t.string :page_name

      t.timestamps
    end
  end
end
